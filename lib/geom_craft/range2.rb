# https://zenn.dev/megeton/articles/0ace7ce5d23f48
# https://docs.rs/nannou/0.18.1/nannou/geom/range/struct.Range.html

module GeomCraft
  class Range2
    class << self
      def [](...)
        new(...)
      end

      def one; 1.0; end
      def zero; 0.0; end

      def from_pos_and_len(pos, len)
        half_len = len / 2.0
        start = pos - half_len
        _end = pos + half_len
        new(start, _end)
      end

      def map_range(val, in_min, in_max, out_min, out_max)
        (val.to_f - in_min) / (in_max - in_min) * (out_max - out_min) + out_min
      end

      def clamp(value, start, _end)
        if start <= _end
          if value < start
            start
          elsif value > _end
            _end
          else
            value
          end
        else
          if value < _end
            _end
          elsif value > start
            start
          else
            value
          end
        end
      end
    end

    attr_accessor :start
    attr_accessor :end

    def initialize(start, _end)
      @start = start
      @end = _end
    end

    def magnitude
      @end - @start
    end

    def length
      mag = magnitude
      if mag < self.class.zero
        -mag
      else
        mag
      end
    end

    def middle
      (@end + @start).fdiv(2)
    end

    def invert
      self.class.new(@end, @start)
    end

    def map_value(value, other)
      self.class.map_range(value, @start, @end, other.start, other.end)
    end

    def lerp(amount)
      @start + (@end - @start) * amount
    end

    def shift(amount)
      self.class.new(@start + amount, @end + amount)
    end

    def direction
      if @start < @end
        self.class.one
      elsif @start > @end
        -self.class.one
      else
        self.class.zero
      end
    end

    def absolute
      if @start > @end
        invert
      else
        self
      end
    end

    def max(other)
      start = [@start, @end, other.start, other.end].min
      _end = [@start, @end, other.start, other.end].max
      self.class.new(start, _end)
    end

    def overlap(other)
      a = absolute
      other = other.absolute
      start = [a.start, other.start].max
      _end = [a.end, other.end].min
      magnitude = _end - start
      if magnitude >= self.class.zero
        self.class.new(start, _end)
      end
    end

    def max_directed(other)
      if @start <= @end
        max(other)
      else
        max(other).invert
      end
    end

    def contains?(pos)
      a = absolute
      a.start <= pos && pos <= a.end
    end

    def round(...); self.class.new(@start.round(...), @end.round(...)); end
    def floor(...); self.class.new(@start.floor(...), @end.floor(...)); end
    def ceil(...); self.class.new(@start.ceil(...), @end.ceil(...)); end
    def truncate(...); self.class.new(@start.truncate(...), @end.truncate(...)); end

    def pad_start(pad); self.class.new(@start + (@start <= @end ? pad : -pad), @end); end
    def pad_end(pad); self.class.new(@start, @end + (@start <= @end ? -pad : pad)); end
    def pad(pad); pad_start(pad).pad_end(pad); end
    def pad_ends(start, _end); pad_start(start).pad_end(_end); end

    def clamp_value(value)
      self.class.clamp(value, @start, @end)
    end

    def stretch_to_value(value)
      if @start <= @end
        if value < @start
          self.class.new(value, @end)
        elsif value > @end
          self.class.new(@start, value)
        else
          self
        end
      else
        if value < @end
          self.class.new(@start, value)
        elsif value > @start
          self.class.new(value, @end)
        else
          self
        end
      end
    end

    def same_direction?(other)
      self_direction = @start <= @end
      other_direction = other.start <= other.end
      self_direction == other_direction
    end

    def align_start_of(other)
      if same_direction?(other)
        diff = other.start - @start
      else
        diff = other.start - @end
      end
      shift(diff)
    end

    def align_end_of(other)
      if same_direction?(other)
        diff = other.end - @end
      else
        diff = other.end - @start
      end
      shift(diff)
    end

    def align_middle_of(other)
      diff = other.middle - middle
      shift(diff)
    end

    def align_after(other)
      if same_direction?(other)
        diff = other.end - @start
      else
        diff = other.end - @end
      end
      shift(diff)
    end

    def align_before(other)
      if self.same_direction?(other)
        diff = other.start - @end
      else
        diff = other.start - @start
      end
      shift(diff)
    end

    def align_to(align, other)
      public_send("align_#{align}_of", other)
    end

    def closest_edge(scalar)
      if scalar < @start
        start_diff = @start - scalar
      else
        start_diff = scalar - @start
      end
      if scalar < @end
        end_diff = @end - scalar
      else
        end_diff = scalar - @end
      end
      if start_diff <= end_diff
        :start
      else
        :end
      end
    end

    ################################################################################

    def to_a
      [@start, @end]
    end

    def ==(other)
      self.class == other.class && @start == other.start && @end == other.end
    end

    def eql?(other)
      self.class == other.class && @start == other.start && @end == other.end
    end

    def hash
      self.class.hash ^ @start.hash ^ @end.hash
    end

    def <=>(other)
      [self.class, @start, @end] <=> [other.class, other.start, other.end]
    end

    def inspect
      "(#{@start} -> #{@end})"
    end

    def to_s
      "(#{@start} -> #{@end})"
    end
  end
end

if $0 == __FILE__
  Range2 = GeomCraft::Range2

  require "rspec/autorun"

  RSpec.configure do |config|
    config.expect_with :test_unit
  end

  describe Range2 do
    it "new" do
      assert { Range2.new(1, 2) == Range2.new(1, 2) }
    end

    it "pos を中心に半径 len / 2 の幅とする (重要)" do
      assert { Range2::from_pos_and_len(100.0, 10.0) == Range2.new(95.0, 105.0) }
    end

    it "それぞれの値" do
      assert { Range2.new(100.0, 200.0).start == 100.0 }
      assert { Range2.new(100.0, 200.0).middle == 150.0 }
      assert { Range2.new(100.0, 200.0).end == 200.0 }
    end

    describe "ベクトルの強さと長さ" do
      it "強さ (end - start)" do
        assert { Range2.new(100, -200).magnitude == -300 }
      end

      it "長さ (強さの絶対値)" do
        assert { Range2.new(100, -200).length == 300 }
      end
    end

    it "小数の補正" do
      assert { Range2.new(0.4, 0.5).round == Range2.new(0, 1) }
      assert { Range2.new(0.4, 0.5).floor == Range2.new(0, 0) }
      assert { Range2.new(0.4, 0.5).ceil == Range2.new(1, 1) }
      assert { Range2.new(0.4, 0.5).truncate == Range2.new(0, 0) }
    end

    describe "範囲" do
      it "OR (向きを破壊する)" do
        a = Range2.new(5.0, 3.0)
        b = Range2.new(4.0, 6.0)
        assert { a.max(b) == Range2.new(3.0, 6.0) }
      end

      it "OR (向きを維持する)" do
        a = Range2.new(5.0, 3.0)
        b = Range2.new(4.0, 6.0)
        assert { a.max_directed(b) == Range2.new(6.0, 3.0) }
      end

      it "AND (向きを破壊する)" do
        a = Range2.new(5.0, 3.0)
        b = Range2.new(4.0, 6.0)
        assert { a.overlap(b) == Range2.new(4.0, 5.0) }
      end
    end

    describe "向き" do
      it "現在の向きを返す" do
        assert { Range2.new(0, 10).direction == 1.0 }
        assert { Range2.new(10, 0).direction == -1.0 }
        assert { Range2.new(10, 10).direction == -0.0 }
      end

      it "向きが同じか？" do
        a = Range2.new(1, 2)
        b = Range2.new(3, 4)
        assert { a.same_direction?(b) == true }
      end

      it "向きを反転する" do
        assert { Range2.new(0, 100).invert == Range2.new(100, 0) }
      end

      it "正の向きにする" do
        assert { Range2.new(10, 0).absolute == Range2.new(0, 10) }
      end
    end

    describe "スケーリング" do
      it "map_value" do
        a = Range2.new(0.0, 1.0)
        b = Range2.new(0.0, 100.0)
        assert { a.map_value(0.9, b) == 90.0 }
      end

      it "元の範囲が 0..1 の場合 lerp 使うと簡潔に書ける" do
        b = Range2.new(0.0, 100.0)
        assert { b.lerp(0.9) == 90.0 }
      end
    end

    describe "指定の軸で整列する" do
      it "相手の左端に揃える" do
        a = Range2.new(0, 100)
        b = Range2.new(50, 100)
        assert { a.align_start_of(b) == Range2.new(50, 150) }
      end

      it "相手の右端に揃える" do
        a = Range2.new(0, 50)
        b = Range2.new(0, 100)
        assert { a.align_end_of(b) == Range2.new(50, 100) }
      end

      it "相手の中央に揃える" do
        a = Range2.new(0.0, 50.0)
        b = Range2.new(0.0, 100.0)
        assert { a.align_middle_of(b) == Range2.new(25.0, 75.0) }
      end

      it "相手のどこかに揃える" do
        a = Range2.new(0.0, 5.0)
        b = Range2.new(10.0, 20.0)
        assert { a.align_to(:start, b) == Range2.new(10.0, 15.0) }
        assert { a.align_to(:end, b) == Range2.new(15.0, 20.0) }
        assert { a.align_to(:middle, b) == Range2.new(12.5, 17.5) }
      end
    end

    describe "横に並べる" do
      it "相手の左隣り並べる" do
        a = Range2.new(0.0, 5.0)
        b = Range2.new(0.0, 10.0)
        assert { a.align_after(b) == Range2.new(10.0, 15.0) }
      end

      it "相手の右隣り並べる" do
        a = Range2.new(0.0, 5.0)
        b = Range2.new(0.0, 0.0)
        assert { a.align_before(b) == Range2.new(-5.0, 0.0) }
      end
    end

    describe "Edge を寄せる (サイズが変わる)" do
      it "左端を内側に寄せる" do
        assert { Range2.new(10, 0).pad_start(3) == Range2.new(7, 0) }
      end

      it "右端を内側に寄せる" do
        assert { Range2.new(10, 0).pad_end(3) == Range2.new(10, 3) }
      end

      it "両端を内側に寄せる" do
        assert { Range2.new(10, 0).pad(3) == Range2.new(7, 3) }
      end

      it "両端を内側に寄せる (個別指定)" do
        assert { Range2.new(10, 0).pad_ends(3, 4) == Range2.new(7, 4) }
      end
    end

    it "この範囲に含むか？" do
      assert { Range2.new(1, 2).contains?(2) == true }
    end

    it "対象を補正する" do
      assert { Range2.new(10, 0).clamp_value(-1) == 0 }
      assert { Range2.new(10, 0).clamp_value(11) == 10 }
    end

    it "ずらす (サイズ不変)" do
      assert { Range2.new(2, 3).shift(10) == Range2.new(12, 13) }
    end

    it "近い方の端を引き伸ばす" do
      assert { Range2.new(10, 20).stretch_to_value(5) == Range2.new(5, 20) }
      assert { Range2.new(10, 20).stretch_to_value(25) == Range2.new(10, 25) }
    end

    it "範囲内を指定した場合は何も変化しない" do
      assert { Range2.new(10, 20).stretch_to_value(15) == Range2.new(10, 20) }
    end

    it "値に近い方の Edge を返す" do
      assert { Range2.new(0.0, 10.0).closest_edge(4.0) == :start }
      assert { Range2.new(0.0, 10.0).closest_edge(6.0) == :end }
    end

    it "==" do
      assert { Range2.new(1, 2) == Range2.new(1, 2) }
    end
  end
end
# >> ................................
# >> 
# >> Finished in 0.02209 seconds (files took 0.08981 seconds to load)
# >> 32 examples, 0 failures
# >> 
