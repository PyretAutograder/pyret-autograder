
provide:
  data Color,
  image-data-to-image,
  image,
  type Image
end

import image as I
import image-structs as IS
import valueskeleton as VS

fun is-valid-component(n :: Number) -> Boolean:
  (n >= 0) and (n <= 255)
end

fun is-valid-dimension(n :: Number) -> Boolean:
  num-is-integer(n) and num-is-positive(n)
end

type Component = Number%(is-valid-component)
type Dimension = Number%(is-valid-dimension)

data Color:
  | color(red :: Component, green :: Component, blue :: Component)
end

newtype Image as ImageT

fun image(width :: Dimension, height :: Dimension):

  fun make(image-data) -> Image block:
    fun to-2d<T>(n :: Number, lst :: List<T>) -> List<List<T>>:
      if is-empty(lst):
        empty
      else:
        split = lst.split-at(n)
        link(split.prefix,
             to-2d(n, split.suffix))
      end
    end

    when (width * height) <> raw-array-length(image-data):
      raise("The number of provided pixels does not match the given width and height.")
    end

    shadow image-data = raw-array-to-list(image-data)

    shadow image-data =
      image-data.map(
        lam(datum):
          ask:
            | is-Color(datum) then: datum
            | is-number(datum) then: color(datum, datum, datum)
            | otherwise: raise("The pixel data includes something that isn't a pixel.")
          end
        end)
    
    viewable = I.color-list-to-bitmap(
      image-data.map({(c): IS.color(c.red, c.green, c.blue, 255)}),
      width, height)

    shadow image-data = to-2d(width, image-data)

    ImageT.brand({
        pixels: image-data,
        width: width,
        height: height,
        method _equals(self, other, er):
          er(self.pixels, other.pixels)
        end,
        method _output(self):
          VS.vs-value(viewable)
        end
    })
  end

  {
    make: make,
    make0: lam(): make([raw-array: ]) end,
    make1: lam(a): make([raw-array: a]) end,
    make2: lam(a, b): make([raw-array: a, b]) end,
    make3: lam(a, b, c): make([raw-array: a, b, c]) end,
    make4: lam(a, b, c, d): make([raw-array: a, b, c, d]) end,
    make5: lam(a, b, c, d, e): make([raw-array: a, b, c, d, e]) end
  }
end

fun image-data-to-image(width :: Dimension, height :: Dimension, image-data :: List<List<Color>>):
  fun flatten-list<X>(xs :: List<List<X>>) -> List<X>:
    xs.foldl(lam(a, b): b.append(a) end, empty)
  end
  image(width,height).make(builtins.raw-array-from-list(flatten-list(image-data)))
end
