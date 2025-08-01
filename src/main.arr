import file("./core.arr") as core
import file("./grading.arr") as grading
import file("./grading-builders.arr") as grading-builders
import file("./graders/main.arr") as graders

provide from core:
  *, type *, data *
end
provide from grading:
  *, type *, data *
end
provide from grading-builders:
  *, type *, data *
end
provide from graders:
  *, type *, data *
end

