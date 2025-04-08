module GeomCraft
  module MathExt
    # https://github.com/godotengine/godot/blob/44e399ed5fa895f760b2995e59788bdb49782666/core/math/math_funcs.cpp#L120
    def snapped(value, step)
      if step.nonzero?
        value = (value / step + 0.5).floor * step
      end
      value
    end
  end
end

Math.extend(GeomCraft::MathExt)
