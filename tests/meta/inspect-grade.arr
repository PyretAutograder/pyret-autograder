include file("../../src/main.arr")
include file("./pp.arr")

provide *

fun inspect-grade(graders) block:
  result = grade(graders)

  print("===================Aggregated===================\n")

  pretty-aggregate = pretty-print-aggregate-results(result.aggregated, 100)
  print(pretty-aggregate + "\n")

  {student-logs; staff-logs} = grading-helpers.summarize-execution-traces(result.trace)

  print("==================Student Logs==================\n")
  print(student-logs.content + "\n")

  print("===================Staff Logs===================\n")
  print(staff-logs.content + "\n")
end
