
provide: liquify-memoization, liquify-dynamic-programming end
# END HEADER
#| wheat(tdelvecc, Sep 4, 2020):
    Basic wheat; follows specs without additional features;
    - Raises an error on negative input.
    - Raises an error if n >= width.
|#

fun liquify-memoization(input :: Image, n :: Number) -> Image block:
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

fun liquify-dynamic-programming(input :: Image, n :: Number) -> Image block:
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
