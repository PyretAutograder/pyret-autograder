import file("../meta/path-utils.arr") as P
import file("../../src/common/ast.arr") as CA
import file("../../src/grading.arr") as G
include file("../../src/graders/image-artifact.arr")
include either
include js-file("../meta/env")

produce-image-artifact = _produce-image-artifact

check "produce-image-artifact: obtains image":
  override-env({ PA_ARTIFACT_DIR: "/tmp/" })

  student = P.file("image-student.arr")
  gen = P.file("artifact.arr")
  produce-image-artifact(student, gen, "out.png") is right({"out.png"; G.png; nothing})

  # TODO: check outputted
end

check "mk-image-artifact: smoke":
  student = P.file("image-student.arr")
  gen = P.file("artifact.arr")
  mk-image-artifact("id", [list:], student, gen, "out.png", "Artifact") does-not-raise
end
