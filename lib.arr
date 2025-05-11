provide: 
  *
end

import ast as A
import file as F
import parse-pyret as PP
import either as E
import pprint as P
import string-dict as SD
import lists as L
import json as J
import option as O
import pathlib as Path
import file("pyret/src/arr/compiler/repl.arr") as R
import file("pyret/src/arr/compiler/cli-module-loader.arr") as CLI
import file("pyret/src/arr/compiler/compile-structs.arr") as CS
import file("pyret/src/arr/compiler/compile-lib.arr") as CL
import runtime-lib as RT
import load-lib as LL

### JSON Helpers

data PJSON:
  | mk(v :: Option<J.JSON>, ops :: List<E.Either<String>>) with:
    method chain(self, op, f):
      cases(Option) self.v:
        | none => mk(none, link(E.left(op + " on no value"), self.ops))
        | some(j) => f(j)
      end
    end,
    method get(self, key :: String):
      op = "get(" + key + ")"
      self.chain(op, lam(j):
          cases(J.JSON) j:
            | j-obj(d) => 
              cases(Option) d.get(key):
                | none => mk(none, link(E.left(op + " missing, keys are " + d.keys.torepr()), self.ops))
                | some(val) => mk(some(val), link(E.right(op), self.ops))
              end
            | else => mk(none, link(E.left(op + " not an object"), self.ops))
          end
        end)
    end,
    method find-match(self, key :: String, val :: String):
      op = "find-match(" + key + " = " + val + ")"
      self.chain(op, lam(j):
          cases(J.JSON) j:
            |j-arr(l) => 
              cases(Option) L.find(
                    lam(o): cases(J.JSON) o:
                        | j-obj(d) => d.get(key) == some(J.j-str(val))
                        | else => false
                      end
                    end, l):
                | none => mk(none, link(E.left(op + " matches nothing against object summaries: " + 
                        torepr(l.map(lam(o): cases(J.JSON) o:
                                | j-obj(d) => d.keys()
                                | else => "nonobj"
                              end
                            end))), self.ops))
                | some(v) => mk(some(v), link(E.right(op), self.ops))
              end
            | else => mk(none, link(E.left(op + " not an array"), self.ops))
          end
        end)
    end,
    method n(self):
      cases(Option) self.v:
        | none => E.left(self.ops)
        | some(j) =>
          cases(J.JSON) j:
            | j-num(num) => E.right(num)
            | else => E.left(link("n()", self.ops))
          end
      end
    end
end

fun pson(j :: J.JSON):
  mk(some(j), empty)
end

### VISITOR HELPERS

fun make-fun-splicer(fun-to-splice):
  A.default-map-visitor.{
    is-top-level : true,
    method s-fun(self, l, name, params, args, ann, doc, body, _check-loc, _check, blocky):
      is-top-level = self.is-top-level
      shadow self = self.{ is-top-level: false }
      if (name == fun-to-splice.name) and is-top-level:
        A.s-fun(l, name, fun-to-splice.params, fun-to-splice.args, fun-to-splice.ann, fun-to-splice.doc, fun-to-splice.body, fun-to-splice._check-loc, self.option(_check), fun-to-splice.blocky)
      else:
        A.s-fun(l, name, params, args.map(_.visit(self)), ann.visit(self), doc, body.visit(self), _check-loc, self.option(_check), blocky)
      end
    end
  }
end

shadow-visitor = A.default-map-visitor.{
  method s-bind(self, l, _, name, ann): A.s-bind(l, true, name, ann) end
}

fun make-fun-extractor(target-name) block:
  var target = none
  A.default-map-visitor.{
    method get-target(self): target end,
    method s-fun(self, l, name, params, args, ann, doc, body, _check-loc, _check, blocky) block:
      visited = A.s-fun(l, name, params, args.map(_.visit(self)), ann.visit(self), doc, body.visit(self), _check-loc, self.option(_check), blocky)
      when target-name == name:
        target := some(visited)
      end
      visited
    end
  }
end

fun make-check-extractor(target-name :: String) block:
  var target = none
  A.default-map-visitor.{
    method get-target(self): target end,
    method s-check(self, l, name, body, keyword-check) block:
      visited = A.s-check(l, name, body.visit(self), keyword-check)
      when some(target-name) == name:
        target := some(visited)
      end
      visited
    end
  }
end

fun make-check-filter(pred):
  A.default-map-visitor.{
    method s-check(self, l, name, body, keyword-check):
      if pred(name):
        A.s-check(l, name, body.visit(self), keyword-check)
      else:
        A.s-id(l, A.s-name(l, "nothing"))
      end
    end
  }
end

fun make-program-appender(expr):
  A.default-map-visitor.{
    method s-program(self, l, _use, _provide, provided-types, provides, imports, body) block:
      new-body = cases(A.Expr) body:
        | s-block(shadow l, stmts) => A.s-block(l, stmts.append([list: expr]))
        | else => raise("make-program-appender: found a non-s-block inside s-program")
      end
      A.s-program(l, self.option(_use), _provide.visit(self), provided-types.visit(self), provides.map(_.visit(self)), imports.map(_.visit(self)), new-body.visit(self))
  end
  }
end

### API FUNCTIONS
fun load-syntax(path :: String):
  content = F.file-to-string(path)
  maybe-ast = PP.maybe-surface-parse(content, path)
  cases(E.Either) maybe-ast block:
    | left(err) => raise(err)
    | right(ast) => ast
  end
end

fun replace-fun(opts :: 
    { base :: A.Program,
      replacement :: A.Program,
      fun-name :: String }) block:
  
  fun-extractor = make-fun-extractor(opts.fun-name)
  opts.replacement.visit(fun-extractor)
  fun-to-splice = cases(Option) fun-extractor.get-target():
    | none => raise("Missing " + opts.fun-name + " in replacement.")
    | some(c) => c.visit(shadow-visitor)
  end

  fun-splicer = make-fun-splicer(fun-to-splice)

  opts.base.visit(fun-splicer)
end

fun remove-checks(stx :: A.Program):
  stx.visit(make-check-filter(lam(_): false end))
end

fun get-check-named(stx :: A.Program, str :: String) block:
  extractor = make-check-extractor(str)
  stx.visit(extractor)
  extractor.get-target()
end

fun add-to-program(stx :: A.Program, expr :: A.Expr):
  stx.visit(make-program-appender(expr))
end

context = {
  current-load-path: Path.resolve("./"),
  cache-base-dir: Path.resolve("./.pyret/compiled"),
  compiled-read-only-dirs: link("node_modules/pyret-npm/pyret-lang/build/phaseA/lib-compiled", empty)
}
repl = R.make-repl(RT.make-runtime(), [SD.mutable-string-dict:], LL.empty-realm(), context, lam(): CLI.module-finder end)

fun run(ast):
  i = repl.make-definitions-locator(lam(): "" end, CS.standard-globals).{
    method get-module(self):
      CL.pyret-ast(ast)
    end
  }
  result = repl.restart-interactions(i, CS.default-compile-options.{checks-format: "json"})
  LL.render-check-results(result.v).message
end

fun run-with-alternate-impl(student-path, chaff-path, fun-name):
  student = load-syntax(student-path)
  chaff = load-syntax(chaff-path)
  to-run = replace-fun({base: student, replacement: chaff, fun-name: fun-name})

  without-checks = remove-checks(to-run)

  result = run(without-checks)

  json = J.read-json(result)
  
  pson(json).get(student-path).find-match("name", fun-name)
end

fun run-extra-check(student-path, check-path, check-name) block:
  student = load-syntax(student-path)
  
  checks = load-syntax(check-path)
  
  without-checks = remove-checks(student)
  extra-check = cases(Option) get-check-named(checks, check-name):
    | none => raise("Missing check block named " + check-name + " in reference.")
    | some(c) => c
  end
  
  prog = add-to-program(without-checks, extra-check)
  
  #print(prog.tosource().pretty(80))
  
  result = run(prog)

  json = J.read-json(result)
  
  pson(json).get(student-path).find-match("name", check-name)
end
