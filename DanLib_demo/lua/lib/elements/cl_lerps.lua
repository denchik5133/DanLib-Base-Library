function DanLibUI:LerpColor(fract, from, to)
    return Color(Lerp(fract, from.r, to.r), Lerp(fract, from.g, to.g), Lerp(fract, from.b, to.b), Lerp(fract, from.a or 255, to.a or 255))
end

function DanLibUI:LerpVector(frac, from, to, ease)
  local newFract = ease and ease(frac, 0, 1, 1) or DanLibUI:Ease(frac, 0, 1, 1)

  return LerpVector(newFract, from, to)
end

function DanLibUI:LerpAngle(frac, from, to, ease)
  local newFract = ease and ease(frac, 0, 1, 1) or DanLibUI:Ease(frac, 0, 1, 1)

  return LerpAngle(newFract, from, to)
end