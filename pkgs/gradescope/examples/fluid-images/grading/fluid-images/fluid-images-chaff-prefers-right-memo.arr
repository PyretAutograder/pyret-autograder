
provide: liquify-memoization, liquify-dynamic-programming end
# END HEADER
#| chaff (tdelvecc, Sep 4, 2020):
    Flips which seam is preferred in a tie so that the rightmost seam
    is preferred in the memoization implementation.
|#

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

fun liquify-memoization(input :: Image, n :: Number) -> Image block:
  # CHAFF DIFFERENCE: uses buggy seam selection that prefers rightmost seam in a tie
  fun better-seam-right(seam1, seam2):
    cases (SeamEnergy) seam1:
      | no-seam => seam2
      | seam-energy(_, energy1) =>
        cases (SeamEnergy) seam2:
          | no-seam => seam1
          | seam-energy(_, energy2) =>
            if energy1 > energy2:
              seam1
            else:
              seam2
            end
        end
    end
  end
  fun get-best-seam-memo-buggy(energies, width, height) block:
    arr :: Array<Array<Option<SeamEnergy>>> =
      build-array(
        {(_): build-array({(_): none}, width + 2)},
        height)
    fun get-value(row, col):
      cases (Option<SeamEnergy>) arr.get-now(row).get-now(col):
        | none => raise("Value not yet computed.")
        | some(value) => value
      end
    end
    for each(col from range(1, width + 1)):
      arr.get-now(0).set-now(col,
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
          .foldl(better-seam-right, no-seam)
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
      .foldl(better-seam-right, no-seam)
      .seam
      .reverse()
  end
  when (n < 0) or (n >= input.width):
    raise("Invalid n provided.")
  end
  for fold(pixels from input.pixels, iter from range(0, n)):
    width = input.width - iter
    height = input.height
    pixels
      ^ get-energies(_, width, height)
      ^ get-best-seam-memo-buggy(_, width, height)
      ^ remove-seam(_, pixels)
  end
    ^ image-data-to-image(input.width - n, input.height, _)
end
