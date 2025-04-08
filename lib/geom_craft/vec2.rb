# https://zenn.dev/megeton/articles/b407350ad51562
# https://docs.rs/glam/latest/glam/f32/struct.Vec2.html

require "forwardable"
require "geom_craft/rand_norm"

module GeomCraft
  class Vec2
    # https://github.com/godotengine/godot/blob/44e399ed5fa895f760b2995e59788bdb49782666/core/math/math_defs.h#L53
    UNIT_EPSILON = 0.00001
    private_constant :UNIT_EPSILON

    class << self
      def [](...)
        new(...)
      end

      def splat(v); new(v, v); end

      def zero_element; 0.0; end
      def one_element; 1.0; end

      def zero; splat(zero_element); end
      def one; splat(one_element); end
      def neg_one; splat(-one_element); end

      def max; splat(Float::INFINITY); end
      def min; splat(-Float::INFINITY); end

      def infinity; max; end
      def neg_infinity; min; end

      def nan; splat(0.0 / 0.0); end

      def x; new(one_element, zero_element); end
      def y; new(zero_element, one_element); end
      def neg_x; new(-one_element, zero_element); end
      def neg_y; new(zero_element, -one_element); end

      def left; new(-one_element, zero_element); end
      def right; new(+one_element, zero_element); end
      def up; new(zero_element, -one_element); end
      def down; new(zero_element, +one_element); end

      def axes; [x, y]; end

      def rand(...); new(Kernel.rand(...), Kernel.rand(...)); end
      def rand_norm(...); new(RandNorm.call(...), RandNorm.call(...)); end # mu: 0, sigma: 1.0, random: Random.new
    end

    extend Forwardable
    def_delegators :to_a, :each
    def_delegators :to_a, :==, :hash, :<=>;
    def_delegators :to_a, :to_ary, :sum, :[]

    include Enumerable

    attr_accessor :x, :y

    def initialize(x = self.class.zero_element, y = self.class.zero_element)
      @x = x
      @y = y
    end

    def eql?(other)
      self == other
    end

    def to_a
      [x, y]
    end

    def as_json
      { x: x, y: y }
    end

    def to_s
      "(#{x}, #{y})"
    end

    def to_h(prefix: "", suffix: "")
      {
        "#{prefix}x#{suffix}".to_sym => x,
        "#{prefix}y#{suffix}".to_sym => y,
      }
    end

    def inspect
      to_s
    end

    # def scale(s)
    #   self * s
    # end

    def min(other); self.class.new([x, other.x].min, [y, other.y].min); end
    def max(other); self.class.new([x, other.x].max, [y, other.y].max); end

    def clamp(min, max)
      min.cmple(max).all? or raise "clamp: expected min <= max"
      max(min).min(max)
    end

    # https://github.com/godotengine/godot/blob/44e399ed5fa895f760b2995e59788bdb49782666/core/math/vector2.cpp#L138
    def snapped(step)
      self.class.new(Math.snapped(x, step.x), Math.snapped(y, step.y))
    end

    def min_element; to_a.min; end
    def max_element; to_a.max; end

    def cmpeq(other); self.class.new(x == other.x, y == other.y); end
    def cmpne(other); self.class.new(x != other.x, y != other.y); end
    def cmpge(other); self.class.new(x >= other.x, y >= other.y); end
    def cmpgt(other); self.class.new(x >  other.x, y >  other.y); end
    def cmple(other); self.class.new(x <= other.x, y <= other.y); end
    def cmplt(other); self.class.new(x <  other.x, y <  other.y); end

    def abs
      self.class.new(x.abs, y.abs)
    end

    def sign
      self.class.new(
        x.negative? ? -1 : 1,
        y.negative? ? -1 : 1,
        )
    end

    def signum
      sign
    end

    def copysign(other)
      abs * other.signum
    end

    def finite?
      all?(&:finite?)
    end

    def nan?
      any?(&:nan?)
    end

    def nan_mask
      self.class.new(x.nan?, y.nan?)
    end

    def zero?; all?(&:zero?); end
    def nonzero?; all?(&:nonzero?); end

    def length_squared; dot(self); end
    def length; Math.sqrt(dot(self)); end

    def norm; length; end
    def mag; length; end
    def magnitude; length; end

    def length_recip; 1.0 / length; end

    def distance_to(other); (other - self).length; end
    def distance_squared_to(other); (other - self).length_squared; end

    ################################################################################

    def normalize
      normalized = self * length_recip
      normalized.finite? or raise
      normalized
    end

    def try_normalize
      rcp = length_recip
      if rcp.finite? && rcp.positive?
        self * rcp
      end
    end

    def normalize_or_zero
      try_normalize || self.class.zero
    end

    def normalized?
      (length_squared - 1.0).abs < UNIT_EPSILON
    end

    ################################################################################

    def project_onto(other)
      other_len_sq_rcp = 1.0 / other.length_squared
      other_len_sq_rcp.finite? or raise
      other * dot(other) * other_len_sq_rcp
    end

    def reject_from(other)
      self - project_onto(other)
    end

    def project_onto_normalized(other)
      other.normalized? or raise
      other * dot(other)
    end

    def reject_from_normalized(other)
      self - project_onto_normalized(other)
    end

    ################################################################################

    def slide(normal)
      self - project_onto_normalized(normal)
    end

    def bounce(normal)
      self - project_onto_normalized(normal) * 2
    end

    def reflect(normal)
      project_onto_normalized(normal) * 2 - self
    end

    ################################################################################

    def round(...); self.class.new(x.round(...), y.round(...)); end
    def floor(...); self.class.new(x.floor(...), y.floor(...)); end
    def ceil(...); self.class.new(x.ceil(...), y.ceil(...)); end
    def truncate(...); self.class.new(x.truncate(...), y.truncate(...)); end
    def trunc(...); truncate(...); end
    def fract; self - floor; end

    ################################################################################

    def exp
      self.class.new(Math.exp(x), Math.exp(y))
    end

    def pow(...)
      self.class.new(x.pow(...), y.pow(...))
    end

    def recip
      self.class.new(1.0 / x, 1.0 / y)
    end

    def lerp(other, s)
      self + (other - self) * s
    end

    def mix(...)
      lerp(...)
    end

    def abs_diff_eq(other, max_abs_diff)
      sub(other).abs.cmple(self.class.splat(max_abs_diff)).all?
    end

    ################################################################################

    def clamp_length(min, max)
      min <= max or raise
      length_sq = length_squared
      if length_sq < min * min
        min * self / Math.sqrt(length_sq)
      elsif length_sq > max * max
        max * self / Math.sqrt(length_sq)
      else
        self
      end
    end

    def clamp_length_max(max)
      length_sq = length_squared
      if length_sq > max * max
        max * self / Math.sqrt(length_sq)
      else
        self
      end
    end

    def clamp_length_min(min)
      length_sq = length_squared
      if length_sq < min * min
        min * self / Math.sqrt(length_sq)
      else
        self
      end
    end

    ################################################################################

    class << self
      def from_angle(angle)
        new(Math.cos(angle), Math.sin(angle))
      end
    end

    # https://github.com/godotengine/godot/blob/44e399ed5fa895f760b2995e59788bdb49782666/core/math/vector2.cpp#L81
    def angle_to(other)
      Math.atan2(cross(other), dot(other))
    end

    def angle_between(other)
      angle_to(other)
    end

    # https://github.com/godotengine/godot/blob/44e399ed5fa895f760b2995e59788bdb49782666/core/math/vector2.cpp#L84
    def angle_to_point(other)
      (other - self).angle
    end

    def angle
      Math.atan2(y, x)
    end

    def rotate(other)
      # https://docs.rs/nannou_core/0.18.0/src/nannou_core/math.rs.html#92
      unless other.kind_of?(self.class)
        other = V.from_angle(other)
      end

      # https://docs.rs/glam/lait/src/glam/f32/vec2.rs.html#662
      self.class.new(
        x * other.x - y * other.y,
        y * other.x + x * other.y,
        )
    end

    # Experimental
    def rotate_angle_add(rad)
      self.class.from_angle(angle + rad) * length
    end

    ################################################################################

    def dot(other)
      x * other.x + y * other.y
    end

    def inner_product(...); dot(...); end

    ################################################################################

    def cross(other)
      x * other.y - y * other.x
    end

    def perp_dot(...); cross(...); end
    def outer_product(...); cross(...); end

    ################################################################################

    def perp
      right90
    end

    def right90
      self.class.new(-y, x)
    end

    def left90
      self.class.new(y, -x)
    end

    ################################################################################

    def add(other)
      if other.kind_of?(self.class)
        self.class.new(x + other.x, y + other.y)
      else
        self.class.new(x + other, y + other)
      end
    end

    def sub(other)
      if other.kind_of?(self.class)
        self.class.new(x - other.x, y - other.y)
      else
        self.class.new(x - other, y - other)
      end
    end

    def mul(other)
      if other.kind_of?(self.class)
        self.class.new(x * other.x, y * other.y)
      else
        self.class.new(x * other, y * other)
      end
    end

    # pow and `**` are different
    # float doesn't have pow, but it does have `**`.
    def **(other)
      if other.kind_of?(self.class)
        self.class.new(x**other.x, y**other.y)
      else
        self.class.new(x**other, y**other)
      end
    end

    def /(other)
      if other.kind_of?(self.class)
        self.class.new(x / other.x, y / other.y)
      else
        self.class.new(x / other, y / other)
      end
    end

    def div(other)
      if other.kind_of?(self.class)
        self.class.new(x.div(other.x), y.div(other.y))
      else
        self.class.new(x.div(other), y.div(other))
      end
    end

    def fdiv(other)
      if other.kind_of?(self.class)
        self.class.new(x.fdiv(other.x), y.fdiv(other.y))
      else
        self.class.new(x.fdiv(other), y.fdiv(other))
      end
    end

    def ceildiv(other)
      if other.kind_of?(self.class)
        self.class.new(x.ceildiv(other.x), y.ceildiv(other.y))
      else
        self.class.new(x.ceildiv(other), y.ceildiv(other))
      end
    end

    def modulo(other)
      if other.kind_of?(self.class)
        self.class.new(x.modulo(other.x), y.modulo(other.y))
      else
        self.class.new(x.modulo(other), y.modulo(other))
      end
    end

    def +(other)
      add(other)
    end

    def -(other)
      sub(other)
    end

    def *(other)
      mul(other)
    end

    def %(other)
      modulo(other)
    end

    def coerce(other)
      [self, other]
    end

    def -@
      self.class.new(-x, -y)
    end

    def +@
      self
    end

    def neg
      -self
    end

    # def reverse
    #   -self
    # end

    # def mul_add(a, b)
    #   self * a + b
    # end

    ################################################################################

    def xy; self; end
    def yx; self.class.new(y, x); end
    def xx; self.class.new(x, x); end
    def yy; self.class.new(y, y); end

    ################################################################################

    def center; self * 0.5; end
    def middle; self * 0.5; end

    def cover?(other, padding: 0)
      true &&
        ((x - padding)..(x + padding)).cover?(other.x) &&
        ((y - padding)..(y + padding)).cover?(other.y)
    end

    ################################################################################

    def replace(other)
      self.x, self.y = other.to_a
      self
    end

    # def add!(other)    = replace(add(other))
    # def sub!(other)    = replace(sub(other))
    # def mul!(other)    = replace(mul(other))
    # def div!(other)    = replace(div(other))
    # def fdiv!(other)   = replace(fdiv(other))
    # def modulo!(other) = replace(modulo(other))

    if false
      prepend Module.new {
        def initialize(...)
          super
          freeze
        end
      }
    end
  end

  V = Vec2
end

if $0 == __FILE__ && ENV["ATCODER"] != "1"
  V = GeomCraft::V

  $LOAD_PATH.unshift("..")
  require "geom_craft/core_ext"

  require "rspec/autorun"

  RSpec.configure do |config|
    config.expect_with :test_unit
  end

  describe V do
    it "sort" do
      assert { [V[3, 4], V[1, 2]].sort == [V[1, 2], V[3, 4]] }
    end

    it "hash key" do
      assert { V[3, 4] == V[3, 4]  }
      assert { V[3, 4].hash == V[3, 4].hash }
      assert { V[3, 4].eql?(V[3, 4])  }
      a = {V[3, 4] => true}
      assert { a[V[3, 4]] }
    end

    it "rand_norm" do
      assert { V.rand_norm.finite? }
    end

    describe "rotation" do
      before do
        @v0 = V.from_angle(45.deg_to_rad).mul(5)
      end

      it "rotate with radian" do
        v1 = @v0.rotate(45.deg_to_rad)
        assert { v1.angle.rad_to_deg.round(2) == 90.0 }
        assert { v1.length == 5.0 }
      end

      it "rotate_angle_add" do
        v1 = @v0.rotate_angle_add(45.deg_to_rad)
        assert { v1.angle.rad_to_deg.round(2) == 90.0 }
        assert { v1.length == 5.0 }
      end
    end

    it "Enumerable" do
      assert { V[true, true].all?    }
      assert { V[true, true].any?    }
      assert { V[false, false].none? }
      assert { V.one.sum == 2        }
    end

    it "min, max" do
      assert { V[3, 6].min(V[4, 5]) == V[3, 5] }
      assert { V[3, 6].max(V[4, 5]) == V[4, 6] }
    end

    it "normalized?" do
      assert { 1000.times.collect.all? { V.rand.normalize.normalized? } }
    end

    it "pow" do
      assert { V[2, 3]**2     == V[4, 9] }
      assert { V[2, 3].pow(2) == V[4, 9] }
    end

    it "**" do
      assert { V[2.0, 3.0]**2.0 == V[4.0, 9.0] }
    end

    it "distance_to" do
      a = V.zero
      b = V.one
      assert { a.distance_to(b) == b.distance_to(a) }
    end
  end
end

# >> ...........
# >>
# >> Finished in 0.02384 seconds (files took 0.06057 seconds to load)
# >> 11 examples, 0 failures
# >>
