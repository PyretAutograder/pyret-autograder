provide *
provide-types *

data Dir:
  | dir(name :: String, ds :: List<Dir>, fs :: List<File>)
end

data File:
  | file(name :: String, content :: String)
    with:
    method size(self):
      string-length(self.content)
    end
end

type Path = List<String>

fun count<A>(target :: A, a :: List<A>) -> Number:
  el-checker = lam(el, cnt):
    if el == target:
      cnt + 1
    else:
      cnt
    end
  end
  a.foldl(el-checker, 0)
end

fun lst-same-els<A>(a :: List<A>, b :: List<A>) -> Boolean:
  fun same-count(el, acc):
    acc and (count(el, a) == count(el, b))
  end
  (a.length() == b.length()) and a.foldl(same-count, true)
end
