import file("../meta/path-utils.arr") as P
import file("../../src/common/ast.arr") as CA
include file("../../src/graders/image-artifact.arr")

save-image = _save-image

check "save-image: obtains image":
  student = P.file("image-student.arr")
  gen = P.file("artifact.arr")
  save-image(student, gen, P.file("out.png")) is nothing
end
