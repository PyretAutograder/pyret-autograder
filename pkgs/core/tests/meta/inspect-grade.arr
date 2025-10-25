#|
  Copyright (C) 2025 ironmoon <me@ironmoon.dev>

  This file is part of pyret-autograder.

  pyret-autograder is free software: you can redistribute it and/or modify it
  under the terms of the GNU Lesser General Public License as published by the
  Free Software Foundation, either version 3 of the License, or (at your option)
  any later version.

  pyret-autograder is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
  for more details.

  You should have received a copy of the GNU Lesser General Public License
  with pyret-autograder. If not, see <http://www.gnu.org/licenses/>.
|#
include file("../../src/main.arr")
include file("./pp.arr")

provide *

fun inspect-grade(graders, show-student-logs, show-staff-logs) block:
  result = grade(graders)

  print("===================Aggregated===================\n")

  pretty-aggregate = pretty-print-aggregate-results(result.aggregated, 100)
  print(pretty-aggregate + "\n")

  {student-logs; staff-logs} = grading-helpers.summarize-execution-traces(result.trace)

  if show-student-logs block:
    print("==================Student Logs==================\n")
    print(student-logs.content + "\n")
    nothing
  else: nothing end

  if show-staff-logs block:
    print("===================Staff Logs===================\n")
    print(staff-logs.content + "\n")
    nothing
  else: nothing end

  result
end
