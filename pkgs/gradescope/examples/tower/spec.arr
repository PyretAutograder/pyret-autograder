use context autograder-spec
provide: spec end

include graders

fun safe-divide(a :: Number, b :: Number, default :: Number) -> Number:
  doc: "Divide the numbers if b != 0, otherwise return default"
  if b == 0:
    default
  else:
    a / b
  end
end

fun mk-examplar(fn, num, dep, path, constr, typ):
  points = safe-divide(2, num, 0)
  lists.build-list(
    lam(i):
      suff = num-to-string(i + 1)
      constr(
        fn + "-" + typ + "-" + suff, [list: dep], path, 
        fn + "/" + typ + "-" + suff + ".arr",
        fn, points
      )
    end,
    num
  )
end

fun mk-wheats(fn :: String, num :: Number, dep :: String, path :: String):
  mk-examplar(fn, num, dep, path, mk-wheat, "wheat")
end

fun mk-chaffs(fn :: String, num :: Number, dep :: String, path :: String):
  mk-examplar(fn, num, dep, path, mk-chaff, "chaff")
end

fun test-design-recipe-for(
  opts :: {
    fn :: String, arity :: Number,
    min-in :: Number, min-out :: Number,
    wheats :: Number, chaffs :: Number
  },
  deps :: List<String>,
  path :: String
):
  fn = opts.fn
  [list:
    mk-fn-def(fn + "-def", deps, path, fn, opts.arity),
    mk-self-test(fn + "-self-test", [list: fn + "-def"], path, fn, 1),
    mk-test-diversity(fn + "-diversity", [list: fn + "-def"], path, fn, opts.min-in, opts.min-out),
    mk-functional(
      fn + "-functional", [list: fn + "-def"], path, 
      "functionality.arr", fn + ": functionality", 
      4, some(fn))]
  + mk-wheats(fn, opts.wheats, fn + "-diversity", path)
  + mk-chaffs(fn, opts.chaffs, fn + "-diversity", path)
end

fun build-graders(path :: String):
  [list:
    mk-well-formed("wf", [list:], path),
    mk-training-wheels("tw", [list: "wf"], path, false)]
  + test-design-recipe-for({
      fn: "num-rooms", arity: 1,
      min-in: 4, min-out: 3,
      wheats: 2, chaffs: 3
    }, [list: "tw"], path)
  + test-design-recipe-for({
      fn: "max-rooms", arity: 1,
      min-in: 4, min-out: 3,
      wheats: 2, chaffs: 3
    }, [list: "tw"], path)
  + test-design-recipe-for({
      fn: "first-floor", arity: 1,
      min-in: 1, min-out: 1,
      wheats: 2, chaffs: 4
    }, [list: "tw"], path)
  + test-design-recipe-for({
      fn: "is-unbalanced", arity: 1,
      min-in: 3, min-out: 2,
      wheats: 2, chaffs: 4
    }, [list: "tw"], path)
end

spec = build-graders("assignment.arr")
