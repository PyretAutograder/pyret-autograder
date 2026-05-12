
provide: liquify-memoization, liquify-dynamic-programming end
# END HEADER
#| wheat(tdelvecc, Sep 4, 2020):
    - Returns original image on negative input or if n >= width.
    Search "WHEAT DIFFERENCE" for changed code.
|#

fun liquify-memoization(input :: Image, n :: Number) -> Image:
  # WHEAT DIFFERENCE: Returns original image if n < 0 or n >= width.
  if (n < 0) or (n >= input.width):
    input
  else:
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
end

fun liquify-dynamic-programming(input :: Image, n :: Number) -> Image:
  # WHEAT DIFFERENCE: Returns original image if n < 0 or n >= width.
  if (n < 0) or (n >= input.width):
    input
  else:
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
end
