include js-file("../../../src/tools/io")

check:
  get-stdin() is "hello"
end

print("some stdout\n")

send-final('{"foo": "bar"}')

