provide: liquify-memoization, liquify-dynamic-programming end
# END HEADER

include file("submission/assignment-support.arr")
include string-dict

# The two provided functions set `solver` and call the shared `liquify`.
# A wheat/chaff selects its memoization vs dynamic-programming behaviour the
# same way, so the grading files merge cleanly. (merge-impl-stmts replaces
# top-level `fun`s by name but cannot prepend `data`/`var` declarations, so
# `data Solver` and `var solver` must live here in the student program.)
data Solver:
  | dynamic-programming
  | memoization
end
var solver :: Solver = dynamic-programming

data SeamEnergy:
  | no-seam
  | seam-energy(seam :: List<Number>, energy :: Number)
end

fun better-seam(seam1 :: SeamEnergy, seam2 :: SeamEnergy) -> SeamEnergy:
  doc: ```Consumes two SeamEnery's and
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
  
  # The first and last row are all 0s.
  border-row = lists.repeat(width + 2, 0)
  
  # Start with a border row on the bottom, and add row by row on top
  for lists.foldr(result from [list: border-row], pixel-row from pixels):
    # Start with a border 0 on the end, and add pixel by pixel to the left
    for lists.foldr(brightness-row from [list: 0], pixel from pixel-row):
      link(pixel.red + pixel.green + pixel.blue, brightness-row)
    end
      ^ link(0, _) # Add a border 0 to the left of the row
      ^ link(_, result) # Add the row to result
  end
    ^ link(border-row, _) # Add a border row to the top
end

fun get-energies-helper(
    bordered :: List<List<Number>>,
    width :: Number,
    height :: Number) 
  -> List<List<Number>>:
  doc: ```Consumes a List of List of Number's representing the brightness
       of each pixel in the Image, surrounded by a border of
       0 brightness, and produces a List of List of Number's representing
       the energies of each pixel (without the border).```
  fun get-row-energies(
      top :: List<Number>, 
      middle :: List<Number>, 
      bottom :: List<Number>, 
      length :: Number) 
    -> List<Number>:
    doc: ```Consumes three rows of brightnesses and
         produces the energies of the middle row.```
    if length < 3:
      empty
    else:
      # (a + 2d + g) - (c + 2f + i)
      xenergy = 
        (top.get(0) + (2 * middle.get(0)) + bottom.get(0))
        - (top.get(2) + (2 * middle.get(2)) + bottom.get(2))
      
      # (a + 2b + c) - (g + 2h + i)
      yenergy =
        (top.get(0) + (2 * top.get(1)) + top.get(2))
        - (bottom.get(0) + (2 * bottom.get(1)) + bottom.get(2))
      
      # sqrt(xenergy^2 + yenergy^2)
      energy = num-sqrt(num-sqr(xenergy) + num-sqr(yenergy))
      
      # add and recur
      link(energy, 
        get-row-energies(top.rest, middle.rest, bottom.rest, length - 1))
    end
  end
  
  map4(
    get-row-energies,
    # Three rows at a time
    bordered,
    bordered.drop(1),
    bordered.drop(2),
    # Plus a value to keep track of how many values left in row
    lists.repeat(height, width))
end

fun get-energies(
    pixels :: List<List<Number>>, 
    width :: Number, 
    height :: Number) 
  -> List<List<Number>>:
  doc: ```Consumes an Image and
       produces the energies of each pixel in input.```
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
  doc: ```Consumes a List of List of Number's representing the
       energies of each pixel in the original picture, and
       produces a List of Numbers which represent the index of each
       pixel in each row of the original picture that is part
       of the lowest energy seam.```
  # Setup the Array
  arr :: Array<Array<Option<SeamEnergy>>> = 
    build-array(
      {(_): build-array(
          {(_): none},
          width + 2)},
      height)
  
  fun get-value(row :: Number, col :: Number) -> SeamEnergy:
    doc: ```Consumes two Number's and
         produces the value in arr at that position.```
    cases (Option<SeamEnergy>) arr.get-now(row).get-now(col):
      | none => raise("Value not yet computed.")
      | some(value) => value
    end
  end
  
  # Fill in the top row with length-one seams
  for each(col from range(1, width + 1)):
    arr
      .get-now(0)
      .set-now(col, 
      some(seam-energy([list: col - 1], energies.get(0).get(col - 1))))
  end
  
  # Fill in the side borders with no-seam's
  for each(row from range(0, height)) block:
    arr.get-now(row).set-now(0, some(no-seam))
    arr.get-now(row).set-now(width + 1, some(no-seam))
  end

  # Fill in the Array row by row
  for each(row from range(1, height)):
    for each(col from range(1, width + 1)):
      best-prev = 
        [list:
          get-value(row - 1, col - 1),
          get-value(row - 1, col    ),
          get-value(row - 1, col + 1),]
        .foldl(better-seam, no-seam)
      
      new-seam =
        cases (SeamEnergy) best-prev:
          | no-seam => raise("Shouldn't get here")
          | seam-energy(seam, energy) =>
            # Add current pixel to seam
            seam-energy(
              link(col - 1, seam),
              energies.get(row).get(col - 1) + energy)
        end
      
      arr.get-now(row).set-now(col, some(new-seam))
    end
  end

  # Get the best seam from the bottom row
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
  doc: ```Consumes a List of List of Color's and
       removes the pixel in each row corresponding to
       the numbers in seam.```
  for map2(row from pixels, rem from seam):
    parts = row.split-at(rem)
    parts.prefix + parts.suffix.rest
  end
end

fun liquify(input :: Image, n :: Number) -> Image block:
  doc: ``` Consumes an image and a number of times to perform the 
       operation. Returns a reduced image object.```
  when (n < 0) or (n >= input.width):
    raise("Invalid n provided.")
  end
  
  for fold(pixels from input.pixels, iter from range(0, n)):
    width = input.width - iter
    height = input.height
    
    pixels
      ^ get-energies(_, width, height)
      ^ get-best-seam-dp(_, width, height)
      ^ remove-seam(_, pixels)
  end
    ^ image-data-to-image(input.width - n, input.height, _)
end


c1 = color(20, 30, 40) # brightness: 90
c2 = color(70, 10, 20) # brightness: 100
c3 = color(10, 40, 20) # brightness: 70
c4 = color(40, 60, 70) # brightness: 170
c5 = color(20, 10, 30) # brightness: 60

list1 = [list:
  [list: c1, c3, c2, c4, c1, c2, c3, c4],
  [list: c3, c4, c5, c4, c3, c4, c5, c1],
  [list: c2, c2, c1, c2, c3, c1, c4, c5],
  [list: c4, c3, c4, c5, c3, c1, c2, c3],
  [list: c3, c1, c5, c2, c4, c2, c1, c5]]

# Remove starting from top-left and going diagonally down-right
list1-sol-1 = [list:
  [list: c3, c2, c4, c1, c2, c3, c4], # remove 1 seam
  [list: c3, c5, c4, c3, c4, c5, c1],
  [list: c2, c2, c2, c3, c1, c4, c5],
  [list: c4, c3, c4, c3, c1, c2, c3],
  [list: c3, c1, c5, c2, c2, c1, c5]]

list1-sol-5 = [list:
  [list: c3, c4, c4], # remove 5 seams
  [list: c3, c5, c1],
  [list: c2, c2, c5],
  [list: c4, c2, c3],
  [list: c3, c1, c5]]

image1 = image-data-to-image(8, 5, list1)
image1-sol-1 = image-data-to-image(7, 5, list1-sol-1)
image1-sol-5 = image-data-to-image(3, 5, list1-sol-5)

# List with identical low-energy seams
list2 = [list:
  [list: c1, c3, c2, c4, c1, c2, c3, c4, c1, c3, c2, c4, c1],
  [list: c3, c4, c5, c4, c3, c4, c4, c1, c3, c4, c5, c4, c3],
  [list: c2, c2, c1, c2, c3, c1, c4, c5, c2, c2, c1, c2, c3],
  [list: c4, c3, c4, c5, c3, c1, c2, c3, c4, c3, c4, c5, c3],
  [list: c3, c1, c5, c2, c4, c2, c1, c5, c3, c1, c5, c2, c4]]

list2-sol = [list:
  [list: c3, c2, c4, c1, c2, c3, c4, c1, c3, c2, c4, c1],
  [list: c3, c5, c4, c3, c4, c4, c1, c3, c4, c5, c4, c3],
  [list: c2, c2, c2, c3, c1, c4, c5, c2, c2, c1, c2, c3],
  [list: c4, c3, c4, c3, c1, c2, c3, c4, c3, c4, c5, c3],
  [list: c3, c1, c5, c2, c2, c1, c5, c3, c1, c5, c2, c4]]

image2 = image-data-to-image(13, 5, list2)
image2-sol = image-data-to-image(12, 5, list2-sol)

# All-black images: every seam has equal (zero) energy.
black-4x4 = image-data-to-image(4, 4,
  [list:
    [list: color(0,0,0), color(0,0,0), color(0,0,0), color(0,0,0)],
    [list: color(0,0,0), color(0,0,0), color(0,0,0), color(0,0,0)],
    [list: color(0,0,0), color(0,0,0), color(0,0,0), color(0,0,0)],
    [list: color(0,0,0), color(0,0,0), color(0,0,0), color(0,0,0)]])
black-3x4 = image-data-to-image(3, 4,
  [list:
    [list: color(0,0,0), color(0,0,0), color(0,0,0)],
    [list: color(0,0,0), color(0,0,0), color(0,0,0)],
    [list: color(0,0,0), color(0,0,0), color(0,0,0)],
    [list: color(0,0,0), color(0,0,0), color(0,0,0)]])
black-1x4 = image-data-to-image(1, 4,
  [list:
    [list: color(0,0,0)],
    [list: color(0,0,0)],
    [list: color(0,0,0)],
    [list: color(0,0,0)]])

black-2x1 = image-data-to-image(2, 1, [list: [list: color(0, 0, 0), color(0, 0, 0)]])
black-1x1 = image-data-to-image(1, 1, [list: [list: color(0, 0, 0)]])

# Tall (10-row) black-and-white striped image, with a hand-verified
# 6-seam solution. Exercises tall images and border-energy handling.
bw-row = [list:
  color(1, 1, 1), color(0, 0, 0),
  color(255, 255, 255), color(255, 255, 255), color(251, 251, 251),
  color(255, 255, 255), color(253, 253, 253), color(255, 255, 255),
  color(0, 0, 0), color(0, 0, 0)]
bw1 = image-data-to-image(10, 10, lists.repeat(10, bw-row))
bw1-sol-6-row = [list:
  color(0, 0, 0), color(255, 255, 255), color(255, 255, 255), color(0, 0, 0)]
bw1-sol-6 = image-data-to-image(4, 10, lists.repeat(10, bw1-sol-6-row))

# Tall, skinny image (height > 2*width): catches a chaff that refuses tall images.
black-2x5 = image-data-to-image(2, 5, lists.repeat(5, [list: color(0,0,0), color(0,0,0)]))
black-1x5 = image-data-to-image(1, 5, lists.repeat(5, [list: color(0,0,0)]))

# Border-sensitive image: the lowest-energy seam is the left-edge column, so a
# chaff that pads the border with the wrong brightness removes a different seam.
norm-4x4 = image-data-to-image(4, 4,
  lists.repeat(4, [list: color(5,5,5), color(0,0,0), color(5,5,5), color(0,0,0)]))
norm-4x4-sol-1 = image-data-to-image(3, 4,
  lists.repeat(4, [list: color(0,0,0), color(5,5,5), color(0,0,0)]))

fun liquify-memoization(input :: Image, n :: Number) -> Image block:
  solver := memoization
  liquify(input, n)
where:
  # smallest image; also exercises n = 0 (remove nothing)
  liquify-memoization(black-2x1, 1).pixels is black-1x1.pixels
  liquify-memoization(black-2x1, 0).pixels is black-2x1.pixels
  # all-black: equal-energy seams, multi-seam removal
  liquify-memoization(black-4x4, 0).pixels is black-4x4.pixels
  liquify-memoization(black-4x4, 1).pixels is black-3x4.pixels
  liquify-memoization(black-4x4, 3).pixels is black-1x4.pixels
  # non-uniform image: seam goes top-left to bottom-right; tie-breaking matters
  liquify-memoization(image1, 1).pixels is image1-sol-1.pixels
  liquify-memoization(image1, 5).pixels is image1-sol-5.pixels
  # wider image with identical low-energy seams
  liquify-memoization(image2, 1).pixels is image2-sol.pixels
  # tall (10-row) image
  liquify-memoization(bw1, 6).pixels is bw1-sol-6.pixels
  liquify-memoization(bw1, 0).pixels is bw1.pixels
  # tall skinny image (height > 2*width): catches tall-refusing chaff
  liquify-memoization(black-2x5, 1).pixels is black-1x5.pixels
  # border-sensitive: lowest-energy seam is the left edge column
  liquify-memoization(norm-4x4, 1).pixels is norm-4x4-sol-1.pixels
end

fun liquify-dynamic-programming(input :: Image, n :: Number) -> Image block:
  solver := dynamic-programming
  liquify(input, n)
where:
  liquify-dynamic-programming(black-2x1, 1).pixels is black-1x1.pixels
  liquify-dynamic-programming(black-2x1, 0).pixels is black-2x1.pixels
  liquify-dynamic-programming(black-4x4, 0).pixels is black-4x4.pixels
  liquify-dynamic-programming(black-4x4, 1).pixels is black-3x4.pixels
  liquify-dynamic-programming(black-4x4, 3).pixels is black-1x4.pixels
  liquify-dynamic-programming(image1, 1).pixels is image1-sol-1.pixels
  liquify-dynamic-programming(image1, 5).pixels is image1-sol-5.pixels
  liquify-dynamic-programming(image2, 1).pixels is image2-sol.pixels
  liquify-dynamic-programming(bw1, 6).pixels is bw1-sol-6.pixels
  liquify-dynamic-programming(bw1, 0).pixels is bw1.pixels
  liquify-dynamic-programming(black-2x5, 1).pixels is black-1x5.pixels
  liquify-dynamic-programming(norm-4x4, 1).pixels is norm-4x4-sol-1.pixels
end
