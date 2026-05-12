
provide: liquify-memoization, liquify-dynamic-programming end
# END HEADER
#| chaff (tdelvecc, Sep 4, 2020):
    Makes the border all brightness 10 instead of 0 in the dynamic-programming impl.
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
  # CHAFF DIFFERENCE: uses border brightness 10 instead of 0
  fun get-bordered-brightnesses-buggy(pixels, width, height):
    border-brightness = 10
    border-row = lists.repeat(width + 2, border-brightness)
    for lists.foldr(result from [list: border-row], pixel-row from pixels):
      for lists.foldr(brightness-row from [list: border-brightness], pixel from pixel-row):
        link(pixel.red + pixel.green + pixel.blue, brightness-row)
      end
        ^ link(border-brightness, _)
        ^ link(_, result)
    end
      ^ link(border-row, _)
  end
  fun get-energies-buggy(pixels, width, height):
    pixels
      ^ get-bordered-brightnesses-buggy(_, width, height)
      ^ get-energies-helper(_, width + 2, height + 2)
  end
  when (n < 0) or (n >= input.width):
    raise("Invalid n provided.")
  end
  for fold(pixels from input.pixels, iter from range(0, n)):
    width = input.width - iter
    height = input.height
    pixels
      ^ get-energies-buggy(_, width, height)
      ^ get-best-seam-dp(_, width, height)
      ^ remove-seam(_, pixels)
  end
    ^ image-data-to-image(input.width - n, input.height, _)
end
