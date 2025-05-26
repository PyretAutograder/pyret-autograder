import timing as T

provide:
  init-time,
  time,
end

data Box: box(ref val) end

fun init-time():
  box(T.time-now())
end

fun time(ctx) block:
  curr = T.time-now()
  diff = curr - ctx!val
  ctx!{val: curr}
  diff
end
