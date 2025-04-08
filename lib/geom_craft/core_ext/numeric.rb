module GeomCraft
  module AngleConvert
    TAU = 2 * Math::PI
    ONE_TURN_DEGREES = 360.0

    def rad_to_deg
      self * ONE_TURN_DEGREES / TAU
    end

    def rad_to_turn
      self / TAU
    end

    def rad_to_rad
      self
    end

    def deg_to_rad
      self * TAU / ONE_TURN_DEGREES
    end

    def deg_to_turn
      self / ONE_TURN_DEGREES
    end

    def deg_to_deg
      self
    end

    def turn_to_deg
      self * ONE_TURN_DEGREES
    end

    def turn_to_rad
      self * TAU
    end

    def turn_to_turn
      self
    end
  end
end

Numeric.include(GeomCraft::AngleConvert)
