import js-file("./proj-dir") as PD
import filesystem as F

provide:
  file,
  example
end

proj-dir = PD.get-proj-dir()

fun file(path :: String):
  files-dir = F.join(proj-dir, "tests/files/")
  F.join(files-dir, path)
end

fun example(path :: String):
  examples-dir = F.join(proj-dir, "tests/examples/")
  F.join(examples-dir, path)
end
