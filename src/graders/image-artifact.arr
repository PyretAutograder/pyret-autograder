import file("../core.arr") as C
import file("../grading.arr") as G
import file("../grading-builders.arr") as GB
import file("../common/markdown.arr") as MD
import file("../common/repl-runner.arr") as R

import runtime-lib as RT
import load-lib as LL

include from C:
  type Id
end

provide:
  save-image as _save-image
end

# data ImageArtifactBlock:

# end

fun save-image(
  student-path :: String,
  generator-path :: String,
  save-to :: String
) -> Nothing:
  res = R.run-for-answer(student-path, generator-path)
  spy: res end
  nothing
end
