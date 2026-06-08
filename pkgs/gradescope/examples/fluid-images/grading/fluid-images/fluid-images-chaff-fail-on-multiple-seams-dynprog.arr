provide: liquify-memoization, liquify-dynamic-programming end
# END HEADER
#| chaff (tdelvecc, Sep 4, 2020): 
    Raises an error if n >= 2 in dynamic-programming impl.
    Seach "CHAFF DIFFERENCE" for changed code.
|#

include string-dict
#import broadway-tower from gdrive-js("", "1CJnvFRf-lxLDfGcJ8wb3qLrAiWetrOkN")


# Used by chaffs to adjust behavior for one implementation but not the other.
data Solver:
  | dynamic-programming
  | memoization
end

var solver :: Solver = dynamic-programming

####################################
############  SeamEnergy  ##########
####################################

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
  
  # CHAFF DIFFERENCE: Raises an error if n >= 2.
  when (solver == dynamic-programming) and (n >= 2):
    raise("Invalid n provided for chaff.")
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

fun liquify-dynamic-programming(input :: Image, n :: Number) -> Image block:
  solver := dynamic-programming
  liquify(input, n)
end

fun liquify-memoization(input :: Image, n :: Number) -> Image block:
  solver := memoization
  liquify(input, n)
end
