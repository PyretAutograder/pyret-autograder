data TrafficLight:
  | red
  | yellow
  | green
end

light = red
can-go = cases(TrafficLight) red:
  | red => "no"
  | yellow => "maybe"
  | green => "yes"
end <> "no"

print(can-go)


