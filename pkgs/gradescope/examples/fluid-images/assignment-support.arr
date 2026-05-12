provide: *, type * end

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

####################################
############  SeamEnergy  ##########
####################################

data SeamEnergy:
  | no-seam
  | seam-energy(seam :: List<Number>, energy :: Number)
end

fun better-seam(seam1 :: SeamEnergy, seam2 :: SeamEnergy) -> SeamEnergy:
  doc: ```Consumes two SeamEnergy's and
         produces the one with smaller energy.```
  cases (SeamEnergy) seam1:
    | no-seam => seam2
    | seam-energy(_, energy1) =>
      cases (SeamEnergy) seam2:
        | no-seam => seam1
        | seam-energy(_, energy2) =>
          # Note: This prefers seam2 in a tie.
          if energy1 < energy2:
            seam1
          else:
            seam2
          end
      end
  end
end

####################################
############ get-energies ##########
####################################

fun get-bordered-brightnesses(
    pixels :: List<List<Color>>,
    width :: Number,
    height :: Number)
  -> List<List<Number>>:
  doc: ```Consumes a List of List of Color and
       produces the brightness of each pixel.
       Adds a border of 0s in the process.```

  border-row = lists.repeat(width + 2, 0)

  for lists.foldr(result from [list: border-row], pixel-row from pixels):
    for lists.foldr(brightness-row from [list: 0], pixel from pixel-row):
      link(pixel.red + pixel.green + pixel.blue, brightness-row)
    end
      ^ link(0, _)
      ^ link(_, result)
  end
    ^ link(border-row, _)
end

fun get-energies-helper(
    bordered :: List<List<Number>>,
    width :: Number,
    height :: Number)
  -> List<List<Number>>:
  fun get-row-energies(
      top :: List<Number>,
      middle :: List<Number>,
      bottom :: List<Number>,
      length :: Number)
    -> List<Number>:
    if length < 3:
      empty
    else:
      xenergy =
        (top.get(0) + (2 * middle.get(0)) + bottom.get(0))
        - (top.get(2) + (2 * middle.get(2)) + bottom.get(2))
      yenergy =
        (top.get(0) + (2 * top.get(1)) + top.get(2))
        - (bottom.get(0) + (2 * bottom.get(1)) + bottom.get(2))
      energy = num-sqrt(num-sqr(xenergy) + num-sqr(yenergy))
      link(energy,
        get-row-energies(top.rest, middle.rest, bottom.rest, length - 1))
    end
  end

  map4(
    get-row-energies,
    bordered,
    bordered.drop(1),
    bordered.drop(2),
    lists.repeat(height, width))
end

fun get-energies(
    pixels :: List<List<Number>>,
    width :: Number,
    height :: Number)
  -> List<List<Number>>:
  pixels
    ^ get-bordered-brightnesses(_, width, height)
    ^ get-energies-helper(_, width + 2, height + 2)
end

####################################
######### Dynamic Programming ######
####################################

fun get-best-seam-dp(
    energies :: List<List<Number>>,
    width :: Number,
    height :: Number)
  -> List<Number> block:
  arr :: Array<Array<Option<SeamEnergy>>> =
    build-array(
      {(_): build-array({(_): none}, width + 2)},
      height)

  fun get-value(row :: Number, col :: Number) -> SeamEnergy:
    cases (Option<SeamEnergy>) arr.get-now(row).get-now(col):
      | none => raise("Value not yet computed.")
      | some(value) => value
    end
  end

  for each(col from range(1, width + 1)):
    arr
      .get-now(0)
      .set-now(col,
      some(seam-energy([list: col - 1], energies.get(0).get(col - 1))))
  end

  for each(row from range(0, height)) block:
    arr.get-now(row).set-now(0, some(no-seam))
    arr.get-now(row).set-now(width + 1, some(no-seam))
  end

  for each(row from range(1, height)):
    for each(col from range(1, width + 1)):
      best-prev =
        [list:
          get-value(row - 1, col - 1),
          get-value(row - 1, col    ),
          get-value(row - 1, col + 1)]
        .foldl(better-seam, no-seam)

      new-seam =
        cases (SeamEnergy) best-prev:
          | no-seam => raise("Shouldn't get here")
          | seam-energy(seam, energy) =>
            seam-energy(
              link(col - 1, seam),
              energies.get(row).get(col - 1) + energy)
        end

      arr.get-now(row).set-now(col, some(new-seam))
    end
  end

  range(0, width + 2)
    .map(get-value(arr.length() - 1, _))
    .foldl(better-seam, no-seam)
    .seam
    .reverse()
end

####################################
############   Liquify    ##########
####################################

fun remove-seam(
    seam :: List<Number>,
    pixels :: List<List<Color>>)
  -> List<List<Color>>:
  for map2(row from pixels, rem from seam):
    parts = row.split-at(rem)
    parts.prefix + parts.suffix.rest
  end
end
