import srcloc as SL
import filelib as FL
import filesystem as FS
import lists as L
import safe-inclusive-substring, filter_n, max from file("../utils.arr")

provide *

fun src-available(srcloc :: SL.Srcloc) -> Boolean:
  cases(SL.Srcloc) srcloc:
    | builtin(module-name) => false
    | srcloc(source, _, _, _, _, _, _) =>
      FS.exists(source) and FL.is-file(source)
  end
end

# TODO: look into char encoding differenced between JS and pyret
fun extract-srcloc(srcloc :: SL.Srcloc) -> {String; String; String}:
  doc: ```
    Exctract the content refrenced by the srcloc surrounded by its context.
    Returns a tuple of three elements where {before; srcloc; after}.
  ```

  cases(SL.Srcloc) srcloc block:
    | builtin(_) => raise("unexpected builtin srcloc")
    | srcloc(source, sline, scol, _, eline, ecol, _) =>
      content = FS.read-file-string(source)
      lines = string-split-all(content, "\n")
      relevant = lines
        ^ filter_n(lam(i, x): (i >= sline) and (i <= eline) end, 1, _)
      len = relevant.length()

      when len < 1:
        spy: srcloc, content, lines, relevant, len end
        raise("invalid srcloc")
      end

      first = relevant.first
      last = relevant.last()

      zero-scol = scol - 1
      zero-ecol = ecol - 1

      # using inclusive substr, so [start idx, end idx];
      substr = safe-inclusive-substring

      #           zero-scol        zero-ecol
      #           v                v
      # ......................................
      # <- pre --><-- referenced --><- post ->
      pre = substr(first, 0, zero-scol - 1) # -1 b/c disjoint
      post = substr(last, zero-ecol + 1, string-length(last) - 1)

      referenced = if len < 2: # first = last
        substr(first, zero-scol, zero-ecol)
      else:
        mid-pre = substr(first, zero-scol, string-length(first) - 1)
        mid-mid = relevant.drop(1).take(relevant.length() - 2)
        mid-post = substr(last, 0, zero-ecol)

        if is-empty(mid-mid):
          mid-pre + "\n" + mid-post
        else:
          mid-pre + "\n" + mid-mid.join-str("\n") + "\n" + mid-post
        end
      end

    {pre; referenced; post}
  end
end

