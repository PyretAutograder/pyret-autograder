
provide: liquify-memoization, liquify-dynamic-programming end
# END HEADER
#| chaff (tdelvecc, Sep 4, 2020):
    Raises an error if n >= 2 in the dynamic-programming implementation.
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
  # CHAFF DIFFERENCE: Raises an error if n >= 2.
  when n >= 2:
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
