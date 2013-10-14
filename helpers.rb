


def scale_value(num, from_min, from_max, to_min, to_max)
  ((((num.to_f - from_min.to_f) / (from_max.to_f - from_min.to_f)) * (to_max.to_f - to_min.to_f)) + to_min.to_f).to_i
end
