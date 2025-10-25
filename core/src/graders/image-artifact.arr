import file("../core.arr") as C
import file("../grading.arr") as G
import file("../grading-builders.arr") as GB
import file("../common/markdown.arr") as MD
import file("../common/repl-runner.arr") as R
import runtime-lib as RT
import load-lib as LL
include either
include from C: type Id end

provide:
  produce-image-artifact as _produce-image-artifact,
  mk-image-artifact,
end

fun produce-image-artifact(
  student-path :: String,
  generator-path :: String,
  save-to :: String
) -> Either<G.InternalError, {String; G.ArtifactFormat; Nothing}>:
  res = R.run-image-save(student-path, generator-path, save-to)
  cases (Either) res:
    | left(err) => 
      left({
        err: err,
        to-string: lam(): to-repr(err) end
      })
    | right(path) => right({path; G.png; nothing})
  end
end

fun mk-image-artifact(
  id :: Id, deps :: List<Id>, student-path :: String, generator-path :: String,
  save-to :: String, # this is relative to PA_ARTIFACT_DIR
  name :: String
):
  producer = lam(): produce-image-artifact(student-path, generator-path, save-to) end
  GB.mk-artist(id, deps, producer, name)
end
