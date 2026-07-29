import file("../core.arr") as C
import file("../grading.arr") as G
import file("../grading-builders.arr") as GB
import file("../common/ast.arr") as CA
import file("../common/markdown.arr") as MD

import ast as A

include either
include from C:
  type Id
end

provide:
  data ImportRequiredBlock,
  data ImportAllowlistBlock,
  mk-import-required,
  mk-import-allowlist,
  check-import-required as _check-import-required,
  check-import-allowlist as _check-import-allowlist,
  fmt-import-required as _fmt-import-required,
  fmt-import-allowlist as _fmt-import-allowlist
end

# --- Shared helpers ---

fun get-imports(path :: String):
  cases (Either) CA.parse-path(path):
    | left(err) => left(err)
    | right(ast) =>
      cases (A.Program) ast:
        | s-program(_, _, _, _, _, imports, _) => right(imports)
      end
  end
end

fun import-module-name(imp) -> Option<String>:
  doc: ```
  Extract the module name string from an import or include AST node.
  Returns none for import forms we don't recognize (e.g. file imports).
  ```
  fun import-type-name(it):
    cases (A.ImportType) it:
      | s-const-import(_, mod) => some(mod)
      | else => none
    end
  end
  ask:
    | A.is-s-import(imp) then: import-type-name(imp.file)
    | A.is-s-include(imp) then: import-type-name(imp.mod)
    | A.is-s-import-fields(imp) then: import-type-name(imp.file)
    | otherwise: none
  end
end

fun import-binding-name(imp) -> Option<String>:
  doc: ```
  Extract the binding name from an import AST node.
  Returns none for include statements (which don't bind to a name).
  ```
  ask:
    | A.is-s-import(imp) then:
      cases (A.Name) imp.name:
        | s-name(_, s) => some(s)
        | else => none
      end
    | otherwise: none
  end
end

# --- Guard 1: Import Required ---

data ImportRequiredBlock:
  | ir-parser-error(err :: CA.ParsePathErr)
  | import-not-found(module-name :: String)
  | wrong-binding(module-name :: String, expected :: String, actual :: String)
end

fun check-import-required(
  path :: String,
  module-name :: String,
  binding :: Option<String>
) -> Option<ImportRequiredBlock>:
  cases (Either) get-imports(path):
    | left(err) => some(ir-parser-error(err))
    | right(imports) =>
      matching = imports.filter(lam(imp):
        import-module-name(imp) == some(module-name)
      end)
      cases (List) matching:
        | empty => some(import-not-found(module-name))
        | link(first, _) =>
          cases (Option) binding:
            | none => none
            | some(expected-binding) =>
              actual = import-binding-name(first)
              cases (Option) actual:
                | none => none
                | some(actual-binding) =>
                  if actual-binding == expected-binding:
                    none
                  else:
                    some(wrong-binding(module-name, expected-binding, actual-binding))
                  end
              end
          end
      end
  end
end

fun fmt-import-required(reason :: ImportRequiredBlock) -> GB.ComboAggregate:
  student = cases (ImportRequiredBlock) reason:
    | ir-parser-error(_) =>
      "Cannot check your imports because we cannot parse your file."
    | import-not-found(mod) =>
      "Cannot find an import for module " + MD.escape-inline-code(mod) +
      ". Make sure you have `import " + MD.escape-inline-code(mod) +
      " as ...` at the top of your file."
    | wrong-binding(mod, expected, actual) =>
      "Module " + MD.escape-inline-code(mod) +
      " is imported as " + MD.escape-inline-code(actual) +
      ", but it should be imported as " + MD.escape-inline-code(expected) + "."
  end ^ G.output-markdown
  staff = none
  {student; staff}
end

fun mk-import-required(
  id :: Id,
  deps :: List<Id>,
  path :: String,
  module-name :: String,
  binding :: Option<String>
):
  name = "Required import " + module-name
  checker = lam(): check-import-required(path, module-name, binding) end
  GB.mk-guard(id, deps, checker, name, fmt-import-required)
end

# --- Guard 2: Import Allowlist ---

data ImportAllowlistBlock:
  | ia-parser-error(err :: CA.ParsePathErr)
  | forbidden-imports(names :: List<String>, allowed :: List<String>)
end

fun check-import-allowlist(
  path :: String,
  allowed :: List<String>
) -> Option<ImportAllowlistBlock>:
  cases (Either) get-imports(path):
    | left(err) => some(ia-parser-error(err))
    | right(imports) =>
      forbidden = imports
        .map(import-module-name)
        .filter(is-some)
        .map(lam(s): s.value end)
        .filter(lam(mod): not(allowed.member(mod)) end)
      if forbidden.length() == 0:
        none
      else:
        some(forbidden-imports(forbidden, allowed))
      end
  end
end

fun fmt-import-allowlist(reason :: ImportAllowlistBlock) -> GB.ComboAggregate:
  student = cases (ImportAllowlistBlock) reason:
    | ia-parser-error(_) =>
      "Cannot check your imports because we cannot parse your file."
    | forbidden-imports(names, allowed) =>
      forbidden-str = names
        .map(MD.escape-inline-code)
        .join-str(", ")
      allowed-str = allowed
        .map(MD.escape-inline-code)
        .join-str(", ")
      "Your program imports modules that are not allowed for this assignment: "
        + forbidden-str + ". "
        + "Only the following modules are permitted: " + allowed-str + "."
  end ^ G.output-markdown
  staff = none
  {student; staff}
end

fun mk-import-allowlist(
  id :: Id,
  deps :: List<Id>,
  path :: String,
  allowed :: List<String>
):
  name = "Allowed imports"
  checker = lam(): check-import-allowlist(path, allowed) end
  GB.mk-guard(id, deps, checker, name, fmt-import-allowlist)
end
