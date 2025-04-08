# https://zenn.dev/megeton/articles/fc94eb1fece2c5
# https://docs.rs/nannou/0.18.1/nannou/geom/rect/struct.Rect.html

if $0 == __FILE__
  $LOAD_PATH.unshift("..")
end

require "geom_craft/vec2"
require "geom_craft/range2"

module GeomCraft
  class Rect
    class << self
      # 指定された x y 座標と w h 次元から Rect を構築する
      def from_x_y_w_h(x, y, w, h)
        new(Range2.from_pos_and_len(x, w), Range2.from_pos_and_len(y, h))
      end

      # 指定された Point と Dimensions から Rect を構築する
      def from_xy_wh(p, s)
        from_x_y_w_h(p.x, p.y, s.x, s.y)
      end

      # 指定された寸法で原点に Rect を構築する
      def from_wh(s)
        from_w_h(s.x, s.y)
      end

      # 指定された幅と高さで原点に Rect を構築する
      def from_w_h(w, h)
        from_x_y_w_h(0.0, 0.0, w, h)
      end

      # 2点の座標から Rect を構築する
      def from_corners(a, b)
        if a.x < b.x
          left, right = a.x, b.x
        else
          left, right = b.x, a.x
        end
        if a.y < b.y
          bottom, top = a.y, b.y
        else
          bottom, top = b.y, a.y
        end
        new(Range2.new(left, right), Range2.new(bottom, top))
      end
    end

    attr_accessor :x
    attr_accessor :y

    def initialize(x, y)
      @x = x
      @y = y
    end

    # x の中央
    def x_middle
      @x.middle
    end

    # y の中央
    def y_middle
      @y.middle
    end

    # 中心
    def x_y
      [x_middle, y_middle]
    end

    # 幅
    def w
      @x.length
    end

    # 高さ
    def h
      @y.length
    end

    # 寸法
    def w_h
      [w, h]
    end

    # 中心と寸法
    def x_y_w_h
      [x_middle, y_middle, w, h]
    end

    # 左上と寸法
    def l_t_w_h
      [left, top, w, h]
    end

    # 左下と寸法
    def l_b_w_h
      [left, bottom, w, h]
    end

    # 長方形の最長辺の長さ
    def length
      [w, h].max
    end

    # Rect の最小の y 値
    def bottom
      @y.absolute.start
    end

    # Rect の最大の y 値
    def top
      @y.absolute.end
    end

    # Rect の最小の x 値
    def left
      @x.absolute.start
    end

    # Rect の最大の x 値
    def right
      @x.absolute.end
    end

    # 辺 (左右下上)
    def l_r_b_t
      [left, right, bottom, top]
    end

    # 境界の中央の xy 位置
    def xy
      V[x_middle, y_middle]
    end

    # Rect の合計寸法
    def wh
      V[w, h]
    end

    # Rect を Point と Dimensions に変換する
    def xy_wh
      [xy, wh]
    end

    # 左上隅位置
    def top_left
      V[left, top]
    end

    # 左下隅位置
    def bottom_left
      V[left, bottom]
    end

    # 右上隅位置
    def top_right
      V[right, top]
    end

    # 右下隅位置
    def bottom_right
      V[right, bottom]
    end

    # 左端の真ん中
    def mid_left
      V[left, y_middle]
    end

    # 上端の真ん中
    def mid_top
      V[x_middle, top]
    end

    # 右端の真ん中
    def mid_right
      V[right, y_middle]
    end

    # 下端の真ん中
    def mid_bottom
      V[x_middle, bottom]
    end

    ################################################################################

    # 指定された Align バリアントに従って、x 軸に沿って self を other に位置を合わせる
    def align_x_of(align, other)
      self.class.new(@x.align_to(align, other.x), @y)
    end

    # 指定された Align バリアントに従って、y 軸に沿って self を other に位置を合わせる
    def align_y_of(align, other)
      self.class.new(@x, @y.align_to(align, other.y))
    end

    # x 軸に沿って、自分の中心を相手の Rect の中心に揃える
    def align_middle_x_of(other)
      self.class.new(@x.align_middle_of(other.x), @y)
    end

    # y 軸に沿って、self の中央を other Rect の中央に揃える
    def align_middle_y_of(other)
      self.class.new(@x, @y.align_middle_of(other.y))
    end

    # 自分を相手の Rect の上端の中央に配置する
    def mid_top_of(other)
      align_middle_x_of(other).align_top_of(other)
    end

    # 自分を相手の Rect の下端の中央に配置する
    def mid_bottom_of(other)
      align_middle_x_of(other).align_bottom_of(other)
    end

    # 自分を相手の Rect の左端の中央に配置する
    def mid_left_of(other)
      align_left_of(other).align_middle_y_of(other)
    end

    # 自分を相手の Rect の右端の中央に配置する
    def mid_right_of(other)
      align_right_of(other).align_middle_y_of(other)
    end

    # 自分を相手の Rect の中央に直接配置する
    def middle_of(other)
      align_middle_x_of(other).align_middle_y_of(other)
    end

    def subdivision_ranges
      x_a = Range2.new(@x.start, x_middle)
      x_b = Range2.new(x_middle, @x.end)
      y_a = Range2.new(@y.start, y_middle)
      y_b = Range2.new(y_middle, @y.end)
      SubdivisionRanges.new(x_a, x_b, y_a, y_b)
    end

    # Rect を x 軸と y 軸に沿って半分に分割し、4 つの細分割を返す
    #
    # サブディビジョンは次の順序で生成されます
    #
    # 1. Bottom left
    # 2. Bottom right
    # 3. Top left
    # 4. Top right
    def subdivisions
      subdivision_ranges.rects
    end

    # 各範囲の大きさが常に正になるように、self を絶対的な Rect に変換する
    def absolute
      self.class.new(@x.absolute, @y.absolute)
    end

    ################################################################################

    # 2 つの Rect が重なる領域を表す Rect
    def overlap(other)
      if x = @x.overlap(other.x) && y = @y.overlap(other.y)
        self.class.new(x, y)
      end
    end

    # 指定された 2 つの Rect セットを包含する Rect
    def max(other)
      self.class.new(@x.max(other.x), @y.max(other.y))
    end

    ################################################################################

    # Rect を x 軸に沿って移動します
    def shift_x(x)
      self.class.new(@x.shift(x), @y)
    end

    # Rect を y 軸に沿って移動します
    def shift_y(y)
      self.class.new(@x, @y.shift(y))
    end

    # 自分の右端を相手の Rect の左端に揃える
    def left_of(other)
      self.class.new(@x.align_before(other.x), @y)
    end

    # 自分の左端を相手の Rect の右端に揃える
    def right_of(other)
      self.class.new(@x.align_after(other.x), @y)
    end

    # 自分の上端を相手の Rectの下端に揃える
    def below(other)
      self.class.new(@x, @y.align_before(other.y))
    end

    # Align self's bottom edge with the top edge of the other Rect.
    def above(other)
      self.class.new(@x, @y.align_after(other.y))
    end

    # 自分の左端を相手の Rect の左端に揃える
    def align_left_of(other)
      self.class.new(@x.align_start_of(other.x), @y)
    end

    # 自分の右端を相手のRectの右端に揃える
    def align_right_of(other)
      self.class.new(@x.align_end_of(other.x), @y)
    end

    # self の下端を other Rect の下端に揃える
    def align_bottom_of(other)
      self.class.new(@x, @y.align_start_of(other.y))
    end

    # 自分の上端を相手の Rect の上端に揃える
    def align_top_of(other)
      self.class.new(@x, @y.align_end_of(other.y))
    end

    # 自分を相手の Rect の左上端に沿って配置する
    def top_left_of(other)
      align_left_of(other).align_top_of(other)
    end

    # 相手の Rect の右上端に沿って自分を配置する
    def top_right_of(other)
      align_right_of(other).align_top_of(other)
    end

    # 自分を相手の Rect の左下の端に沿って配置する
    def bottom_left_of(other)
      align_left_of(other).align_bottom_of(other)
    end

    # 相手の Rect の右下の端に沿って自分を配置する
    def bottom_right_of(other)
      align_right_of(other).align_bottom_of(other)
    end

    # 指定された位置に最も近い角を返す
    CLOSEST_CORNER_TABLE = {
      [:start, :start] => :bottom_left,
      [:start, :end]   => :top_left,
      [:end, :start]   => :bottom_right,
      [:end, :end]     => :top_right,
    }
    def closest_corner(v)
      CLOSEST_CORNER_TABLE.fetch([@x.closest_edge(v.x), @y.closest_edge(v.y)])
    end

    # Rect の四隅
    def corners
      [
        V[@x.start, @y.end],
        V[@x.end,   @y.end],
        V[@x.end,   @y.start],
        V[@x.start, @y.start],
      ]
    end

    # Rect を表す2つの三角形の頂点を返す
    def triangles
      a, b, c, d = corners
      [[a, b, c], [a, c, d]]
    end

    # Rect を指定されたベクトルだけシフトします
    def shift(v)
      shift_x(v.x).shift_y(v.y)
    end

    # 指定された位置が Rectangle に触れているかどうか
    def contains?(v)
      @x.contains?(v.x) && @y.contains?(v.y)
    end

    # 指定された位置が Rect 領域の外側にある場合、その位置に最も近い辺を引き伸ばす
    def stretch_to(v)
      self.class.new(@x.stretch_to_value(v.x), @y.stretch_to_value(v.y))
    end

    # 指定された位置が Rect 領域の外側にある場合、その位置に最も近い辺を引き伸ばす
    def stretch_to_point(v)
      stretch_to(v)
    end

    # 左端にパディングが適用された Rect
    def pad_left(pad)
      self.class.new(@x.pad_start(pad), @y)
    end

    # 右端にパディングが適用された Rect
    def pad_right(pad)
      self.class.new(@x.pad_end(pad), @y)
    end

    # 下端にパディングが適用された四角形
    def pad_bottom(pad)
      self.class.new(@x, @y.pad_start(pad))
    end

    # 上端にパディングが適用された Rect
    def pad_top(pad)
      self.class.new(@x, @y.pad_end(pad))
    end

    # 各辺にある程度のパディング量が適用された Rect
    def pad(pad)
      self.class.new(@x.pad(pad), @y.pad(pad))
    end

    # パディングが適用された Rect
    def padding(padding)
      self.class.new(@x.pad_ends(padding.x.start, padding.x.end), @y.pad_ends(padding.y.start, padding.y.end))
    end

    # x 軸上の指定された位置を基準とした相対位置を持つ Rect を返す
    def relative_to_x(x)
      self.class.new(@x.shift(-x), @y)
    end

    # y 軸上の指定された位置を基準とした相対位置を持つ Rect を返す
    def relative_to_y(y)
      self.class.new(@x, @y.shift(-y))
    end

    # 指定された位置を基準とした相対位置を持つ Rect を返す
    def relative_to(v)
      relative_to_x(v.x).relative_to_y(v.y)
    end

    # X 軸を反転する (別名: Y 軸を中心に反転する)
    def invert_x
      self.class.new(@x.invert, @y)
    end

    # Y 軸を反転する (別名: X 軸を中心に反転する)
    def invert_y
      self.class.new(@x, @y.invert)
    end

    ################################################################################

    def ==(other)
      self.class == other.class && @x == other.x && @y == other.y
    end

    def eql?(other)
      self.class == other.class && @x == other.x && @y == other.y
    end

    def hash
      self.class.hash ^ @x.hash ^ @y.hash
    end

    def <=>(other)
      [self.class, @x, @y] <=> [other.class, other.x, other.y]
    end

    def inspect
      "(#{@x}, #{@y})"
    end

    def to_s
      "(#{@x}, #{@y})"
    end

    SubdivisionRanges = Data.define(:x_a, :x_b, :y_a, :y_b) do
      def rects
        [
          Rect.new(x_a, y_a),
          Rect.new(x_b, y_a),
          Rect.new(x_a, y_b),
          Rect.new(x_b, y_b),
        ]
      end
    end
  end
end

if $0 == __FILE__
  V      = GeomCraft::Vec2
  Range2 = GeomCraft::Range2
  Rect   = GeomCraft::Rect

  require "rspec/autorun"

  RSpec.configure do |config|
    config.expect_with :test_unit
  end

  describe Rect do
    it "x, y, w, h から作る" do
      a = Rect.from_x_y_w_h(0.0, 0.0, 100.0, 100.0)
      assert { a.x == Range2.new(-50.0, 50.0) }
      assert { a.y == Range2.new(-50.0, 50.0) }
    end

    it "w, h から作る" do
      a = Rect.from_w_h(100.0, 100.0)
      assert { a.x == Range2.new(-50.0, 50.0) }
      assert { a.y == Range2.new(-50.0, 50.0) }
    end

    it "対角から作る" do
      assert { Rect.from_corners(V[-10, 10], V[-10, 10]) == Rect.new(Range2.new(-10, -10), Range2.new(10, 10)) }
    end

    it "基本的な値の取得" do
      a = Rect.from_x_y_w_h(10.0, 20.0, 100.0, 100.0)
      assert { a.x_middle == 10.0 }
      assert { a.y_middle == 20.0 }
      assert { a.w == 100.0 }
      assert { a.h == 100.0 }
      assert { a.x_y == [10.0, 20.0] }
      assert { a.w_h == [100.0, 100.0] }
    end

    it "a を b の座標の align に揃える" do
      a = Rect.from_x_y_w_h(0.0, 0.0, 10.0, 10.0)
      b = Rect.from_x_y_w_h(0.0, 0.0, 100.0, 100.0)
      assert { a.align_x_of(:start, b) == Rect.new(Range2.new(-50.0, -40.0), Range2.new(-5.0, 5.0)) }
      assert { a.align_x_of(:middle, b) == Rect.new(Range2.new(-5.0, 5.0), Range2.new(-5.0, 5.0)) }
      assert { a.align_x_of(:end, b) == Rect.new(Range2.new(40.0, 50.0), Range2.new(-5.0, 5.0)) }

      assert { a.align_y_of(:start, b) == Rect.new(Range2.new(-5.0, 5.0), Range2.new(-50.0, -40.0)) }
      assert { a.align_y_of(:middle, b) == Rect.new(Range2.new(-5.0, 5.0), Range2.new(-5.0, 5.0)) }
      assert { a.align_y_of(:end, b) == Rect.new(Range2.new(-5.0, 5.0), Range2.new(40.0, 50.0)) }

      # a.align_x_of(:middle, b) と a.align_y_of(:middle, b) のショートカット:
      assert { a.align_middle_x_of(b) == Rect.new(Range2.new(-5.0, 5.0), Range2.new(-5.0, 5.0)) }
      assert { a.align_middle_y_of(b) == Rect.new(Range2.new(-5.0, 5.0), Range2.new(-5.0, 5.0)) }

      # a を b の内側の上下左右の辺にくっつける
      assert { a.mid_top_of(b) == Rect.new(Range2.new(-5.0, 5.0), Range2.new(40.0, 50.0)) }
      assert { a.mid_bottom_of(b) == Rect.new(Range2.new(-5.0, 5.0), Range2.new(-50.0, -40.0)) }
      assert { a.mid_left_of(b) == Rect.new(Range2.new(-50.0, -40.0), Range2.new(-5.0, 5.0)) }
      assert { a.mid_right_of(b) == Rect.new(Range2.new(40.0, 50.0), Range2.new(-5.0, 5.0)) }

      # a を b の中心に配置する
      assert { a.middle_of(b) == Rect.new(Range2.new(-5.0, 5.0), Range2.new(-5.0, 5.0)) }
    end

    it "中央で区切って上下左右の範囲を返す" do
      a = Rect.from_x_y_w_h(200.0, 300.0, 10.0, 10.0)
      b = a.subdivision_ranges
      assert { b.y_a == Range2.new(295.0, 300.0) }
      assert { b.y_b == Range2.new(300.0, 305.0) }
      assert { b.x_a == Range2.new(195.0, 200.0) }
      assert { b.x_b == Range2.new(200.0, 205.0) }
    end

    it "内部の方向を正にする" do
      a = Rect.new(Range2.new(1.0, -1.0), Range2.new(1.0, -1.0))
      assert { a == Rect.new(Range2.new(1.0, -1.0), Range2.new(1.0, -1.0)) }
      assert { a.absolute == Rect.new(Range2.new(-1.0, 1.0), Range2.new(-1.0, 1.0)) }
    end

    it "AND 領域" do
      a = Rect.from_x_y_w_h(100.0, 100.0, 100.0, 100.0)
      b = Rect.from_x_y_w_h(150.0, 150.0, 100.0, 100.0)
      assert { a.overlap(b) == Rect.new(Range2.new(100.0, 150.0), Range2.new(100.0, 150.0)) }
    end

    it "OR 領域" do
      a = Rect.from_x_y_w_h(100.0, 100.0, 100.0, 100.0)
      b = Rect.from_x_y_w_h(150.0, 150.0, 100.0, 100.0)
      assert { a.max(b) == Rect.new(Range2.new(50.0, 200.0), Range2.new(50.0, 200.0)) }
    end

    it "辺の座標" do
      a = Rect.from_x_y_w_h(100.0, 100.0, 100.0, 100.0)
      assert { a.left == 50.0 }
      assert { a.right == 150.0 }
      assert { a.bottom == 50.0 }
      assert { a.top == 150.0 }

      # まとめて
      assert { a.l_r_b_t == [50.0, 150.0, 50.0, 150.0] }
    end

    it "x y をそれぞれ移動" do
      a = Rect.from_x_y_w_h(0.0, 0.0, 100.0, 100.0)
      assert { a == Rect.new(Range2.new(-50.0, 50.0), Range2.new(-50.0, 50.0)) }
      assert { a.shift_x(25.0) == Rect.new(Range2.new(-25.0, 75.0), Range2.new(-50.0, 50.0)) }
      assert { a.shift_y(25.0) == Rect.new(Range2.new(-50.0, 50.0), Range2.new(-25.0, 75.0)) }
    end

    describe "相手のどこかに移動する" do
      let(:a) { Rect.from_x_y_w_h(0.0, 0.0, 10.0, 10.0)   }
      let(:b) { Rect.from_x_y_w_h(0.0, 0.0, 100.0, 100.0) }

      it "相手の辺の外側に移動する" do
        assert { a.left_of(b) == Rect.new(Range2.new(-60.0, -50.0), Range2.new(-5.0, 5.0)) }
        assert { a.right_of(b) == Rect.new(Range2.new(50.0, 60.0), Range2.new(-5.0, 5.0)) }
        assert { a.below(b) == Rect.new(Range2.new(-5.0, 5.0), Range2.new(-60.0, -50.0)) }
        assert { a.above(b) == Rect.new(Range2.new(-5.0, 5.0), Range2.new(50.0, 60.0)) }
      end

      it "相手の辺の内側に移動する" do
        assert { a.align_left_of(b) == Rect.new(Range2.new(-50.0, -40.0), Range2.new(-5.0, 5.0)) }
        assert { a.align_right_of(b) == Rect.new(Range2.new(40.0, 50.0), Range2.new(-5.0, 5.0)) }
        assert { a.align_bottom_of(b) == Rect.new(Range2.new(-5.0, 5.0), Range2.new(-50.0, -40.0)) }
        assert { a.align_top_of(b) == Rect.new(Range2.new(-5.0, 5.0), Range2.new(40.0, 50.0)) }
      end

      it "相手の角の内側に移動する" do
        assert { a.top_left_of(b) == Rect.new(Range2.new(-50.0, -40.0), Range2.new(40.0, 50.0)) }
        assert { a.top_right_of(b) == Rect.new(Range2.new(40.0, 50.0), Range2.new(40.0, 50.0)) }
        assert { a.bottom_left_of(b) == Rect.new(Range2.new(-50.0, -40.0), Range2.new(-50.0, -40.0)) }
        assert { a.bottom_right_of(b) == Rect.new(Range2.new(40.0, 50.0), Range2.new(-50.0, -40.0)) }
      end
    end

    it "指定の座標を含むように近い方の辺を広げる(比率が壊れる)" do
      a = Rect.from_x_y_w_h(0.0, 0.0, 10.0, 10.0)
      assert { a.stretch_to_point(V[6.0, 6.0]) == Rect.new(Range2.new(-5.0, 6.0), Range2.new(-5.0, 6.0)) }
    end

    it "指定の座標にいちばん近い角の名前を返す" do
      a = Rect.from_x_y_w_h(0.0, 0.0, 10.0, 10.0)
      assert { a.closest_corner(V[1.0, 1.0]) == :top_right }
      assert { a.closest_corner(V[-1.0, -1.0]) == :bottom_left }
      assert { a.closest_corner(V[-1.0, 1.0]) == :top_left }
      assert { a.closest_corner(V[1.0, -1.0]) == :bottom_right }
    end

    it "角の座標を返す" do
      a = Rect.from_x_y_w_h(0.0, 0.0, 10.0, 10.0)
      assert { a.corners == [[-5.0, 5.0], [5.0, 5.0], [5.0, -5.0], [-5.0, -5.0]] }
    end

    it "四角形を斜めに切ってできる三角形を得る" do
      a = Rect.from_x_y_w_h(0.0, 0.0, 10.0, 10.0)
      assert { a.triangles == [[[-5.0, 5.0], [5.0, 5.0], [5.0, -5.0]], [[-5.0, 5.0], [5.0, -5.0], [-5.0, -5.0]]] }
    end

    it "ベクトルや Point2 から作る" do
      assert { Rect.from_xy_wh(V[0.0, 0.0], V[10.0, 10.0]) == Rect.new(Range2.new(-5.0, 5.0), Range2.new(-5.0, 5.0)) }
      assert { Rect.from_wh(V[10.0, 10.0]) == Rect.new(Range2.new(-5.0, 5.0), Range2.new(-5.0, 5.0)) }
    end

    it "基本的な情報の参照" do
      a = Rect.from_wh(V[100.0, 100.0])
      assert { a.xy == V[0.0, 0.0] }
      assert { a.wh == V[100.0, 100.0] }
      assert { a.xy_wh == [V[0.0, 0.0], V[100.0, 100.0]] }

      assert { a.top_left == V[-50.0, 50.0] }
      assert { a.top_right == V[50.0, 50.0] }
      assert { a.bottom_left == V[-50.0, -50.0] }
      assert { a.bottom_right == V[50.0, -50.0] }

      assert { a.mid_left == V[-50.0, 0.0] }
      assert { a.mid_top == V[0.0, 50.0] }
      assert { a.mid_right == V[50.0, 0.0] }
      assert { a.mid_bottom == V[0.0, -50.0] }
    end

    it "x, y をまとめて移動" do
      a = Rect.from_wh(V[100.0, 100.0])
      assert { a.shift(V[10.0, 10.0]) == Rect.new(Range2.new(-40.0, 60.0), Range2.new(-40.0, 60.0)) }
    end

    it "指定の座標が含まれるか？" do
      a = Rect.from_wh(V[100.0, 100.0])
      assert { a.contains?(V[0.0, 0.0]) == true }
      assert { a.contains?(V[0.0, 51.0]) == false }
    end

    it "指定の座標が含まれるまで近い方を伸ばす" do
      a = Rect.from_wh(V[2.0, 2.0])
      assert { a.stretch_to(V[5.0, 5.0]) == Rect.new(Range2.new(-1.0, 5.0), Range2.new(-1.0, 5.0)) }
    end

    it "左上wh や 左下wh をまとめて得る" do
      a = Rect.from_wh(V[100.0, 100.0])
      assert { a.l_t_w_h == [-50.0, 50.0, 100.0, 100.0] }
      assert { a.l_b_w_h == [-50.0, -50.0, 100.0, 100.0] }
    end

    it "領域を内側に縮小する" do
      a = Rect.from_wh(V[100.0, 100.0])
      assert { a.pad_left(10.0) == Rect.new(Range2.new(-40.0, 50.0), Range2.new(-50.0, 50.0)) }
      assert { a.pad_right(10.0) == Rect.new(Range2.new(-50.0, 40.0), Range2.new(-50.0, 50.0)) }
      assert { a.pad_bottom(10.0) == Rect.new(Range2.new(-50.0, 50.0), Range2.new(-40.0, 50.0)) }
      assert { a.pad_top(10.0) == Rect.new(Range2.new(-50.0, 50.0), Range2.new(-50.0, 40.0)) }
      assert { a.pad(10.0) == Rect.new(Range2.new(-40.0, 40.0), Range2.new(-40.0, 40.0)) }
      p = Rect.new(Range2.new(10.0, 10.0), Range2.new(10.0, 10.0))
      assert { a.padding(p) == Rect.new(Range2.new(-40.0, 40.0), Range2.new(-40.0, 40.0)) }
    end

    it "相対的な範囲を返す" do
      a = Rect.from_wh(V[10.0, 10.0])
      assert { a == Rect.new(Range2.new(-5.0, 5.0), Range2.new(-5.0, 5.0)) }
      assert { a.relative_to_x(10.0) == Rect.new(Range2.new(-15.0, -5.0), Range2.new(-5.0, 5.0)) }
      assert { a.relative_to_y(10.0) == Rect.new(Range2.new(-5.0, 5.0), Range2.new(-15.0, -5.0)) }
      assert { a.relative_to(V[10.0, 10.0]) == Rect.new(Range2.new(-15.0, -5.0), Range2.new(-15.0, -5.0)) }
    end

    it "反転" do
      a = Rect.from_wh(V[2.0, 2.0])
      assert { a == Rect.new(Range2.new(-1.0, 1.0), Range2.new(-1.0, 1.0)) }
      assert { a.invert_x == Rect.new(Range2.new(1.0, -1.0), Range2.new(-1.0, 1.0)) }
      assert { a.invert_y == Rect.new(Range2.new(-1.0, 1.0), Range2.new(1.0, -1.0)) }
    end

    it "==" do
      assert { Rect.from_wh(V[2.0, 2.0]) == Rect.from_wh(V[2.0, 2.0]) }
    end
  end
end
# >> ............................
# >>
# >> Finished in 0.04071 seconds (files took 0.06077 seconds to load)
# >> 28 examples, 0 failures
# >>
