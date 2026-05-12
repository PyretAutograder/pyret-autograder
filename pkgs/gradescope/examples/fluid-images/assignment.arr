provide: liquify-memoization, liquify-dynamic-programming end

include file("submission/assignment-support.arr")

fun liquify-memoization(input :: Image, n :: Number) -> Image block:
  doc: ```Consumes an image and a number of seams to remove.
       Returns the reduced image.```
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
  where:
    1 is 1 # bogus test
end

fun liquify-dynamic-programming(input :: Image, n :: Number) -> Image block:
  doc: ```Consumes an image and a number of seams to remove.
       Returns the reduced image.```
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
  where:
    1 is 1 # bogus test
end
