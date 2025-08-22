fun foo():
  var counter = 1
  lam() block:
    counter := counter + 1
    counter
  end
end
