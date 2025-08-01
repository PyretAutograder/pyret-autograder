import file("./well-formed.arr") as well-formed
import file("./self-test.arr") as self-test
import file("./functional.arr") as functional
import file("./examplar.arr") as examplar

# NOTE: only provides the functions, everything else should be an
# implementation detail and can be imported directly from the module
# for tests.
provide from well-formed: * end
provide from self-test: * end
provide from functional: * end
provide from examplar: * end

