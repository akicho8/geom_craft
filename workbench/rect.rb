#+hidden: true
require "./setup"

#+title2: 早見表

# | 種類   | 意味               | Methods            | 同類・補足                                    |
# |--------+--------------------+--------------------+-----------------------------------------------|
# | 生成   | x, y, w, h から    | from_x_y_w_h       | from_xy_wh                                    |
# | 生成   | w, h から          | from_w_h           | from_wh                                       |
# | 生成   | 対角から           | from_corners       |                                               |
# | 参照   | 個別               | x y w h            |                                               |
# | 参照   | 配列               | x_y w_h            |                                               |
# | 参照   | ベクトル型         | xy wh              | xy_wh                                         |
# | 参照   | まとめて           | l_r_b_t            | l_t_w_h l_b_w_h                               |
# | 参照   | 十字の先端         | mid_left           | mid_top mid_right mid_bottom                  |
# | 参照   | 辺                 | left               | right bottom top                              |
# | 角     | 個別               | top_left           | top_right bottom_left bottom_right            |
# | 角     | まとめて           | corners            |                                               |
# | 角     | 座標に近い角の名前 | closest_corner(xy) | stretch_to_point の影響を受ける角が分かる     |
# | 領域   | 上下左右           | subdivision_ranges | subdivisions                                  |
# | 領域   | 対角切断時の三角形 | triangles          |                                               |
# | 対領域 | 相手との AND       | a.overlap(b)       |                                               |
# | 対領域 | 相手との OR        | a.max(b)           |                                               |
# | 移動   | 相手の軸の ? に    | a.align_x_of(?, b) | align_y_of align_middle_of                    |
# | 移動   | 相手の内側の辺に   | a.mid_top_of(b)    | mid_bottom_of mid_left_of mid_right_of        |
# | 移動   | 相手の中心に       | a.middle_of(b)     |                                               |
# | 移動   | 相手の辺の外に     | left_of(b)         | right_of below above                          |
# | 移動   | 相手の辺の内に     | align_left_of(b)   | align_right_of align_bottom_of align_top_of   |
# | 移動   | 相手の角の内に     | top_left_of(b)     | top_right_of bottom_left_of bottom_right_of   |
# | 変形   | 軸を動かす         | shift(vec)         | shift_x shift_y                               |
# | 変形   | 指定座標を覆う     | stretch_to(vec)    | stretch_to_point(vec)                         |
# | 変形   | 縮小               | pad                | pad_left pad_right pad_bottom pad_top padding |
# | 向き   | 反転               | invert_x           | invert_y                                      |
# | 向き   | 正にする           | absolute           |                                               |
# | その他 | 座標が含まれるか？ | contains?(vec)     |                                               |
# | その他 | 相対的な領域を返す | relative_to(xy)    | relative_to_x relative_to_y                   |

#+title2: コンストラクタ

#+title5: x, y, w, h から作る

Rect.from_xy_wh(V[0.0, 0.0], V[10.0, 10.0]) # => ((-5.0 -> 5.0), (-5.0 -> 5.0))
Rect.from_x_y_w_h(0.0, 0.0, 100.0, 100.0)   # => ((-50.0 -> 50.0), (-50.0 -> 50.0))

#+title5: w, h から作る

Rect.from_wh(V[10.0, 10.0])     # => ((-5.0 -> 5.0), (-5.0 -> 5.0))
Rect.from_w_h(100.0, 100.0)     # => ((-50.0 -> 50.0), (-50.0 -> 50.0))

#+title5: 対角から作る

Rect.from_corners(V[-10, 10], V[-10, 10]) # => ((-10 -> -10), (10 -> 10))

#+title2: 基本的な値の取得

a = Rect.from_x_y_w_h(10.0, 20.0, 100.0, 100.0)

#+title5: x, y

[a.x_middle, a.y_middle]       # => [10.0, 20.0]
a.x_y                          # => [10.0, 20.0]
a.xy                           # => (10.0, 20.0)

#+title5: w, h

[a.w, a.h]       # => [100.0, 100.0]
a.w_h     # => [100.0, 100.0]
a.wh     # => (100.0, 100.0)

#+title5: x, y, w, h

a.xy_wh        # => [(10.0, 20.0), (100.0, 100.0)]

#+title5: 角

a.top_left     # => (-40.0, 70.0)
a.top_right    # => (60.0, 70.0)
a.bottom_left  # => (-40.0, -30.0)
a.bottom_right # => (60.0, -30.0)

#+title5: 辺の中央

a.mid_left               # => (-40.0, 20.0)
a.mid_top                # => (10.0, 70.0)
a.mid_right              # => (60.0, 20.0)
a.mid_bottom             # => (10.0, -30.0)

#+title5: 辺

a.left                 # => -40.0
a.right                # => 60.0
a.bottom               # => -30.0
a.top                  # => 70.0

#+title5: まとめて

a.l_r_b_t               # => [-40.0, 60.0, -30.0, 70.0]
a.l_t_w_h               # => [-40.0, 70.0, 100.0, 100.0]
a.l_b_w_h               # => [-40.0, -30.0, 100.0, 100.0]

#+title2: 整列

#+title5: a を b の座標の align に揃える

a = Rect.from_wh(V[10.0, 10.0])
b = Rect.from_wh(V[100.0, 100.0])
a.align_x_of(:start, b)  # => ((-50.0 -> -40.0), (-5.0 -> 5.0))
a.align_x_of(:middle, b) # => ((-5.0 -> 5.0), (-5.0 -> 5.0))
a.align_x_of(:end, b)    # => ((40.0 -> 50.0), (-5.0 -> 5.0))

a.align_y_of(:start, b)  # => ((-5.0 -> 5.0), (-50.0 -> -40.0))
a.align_y_of(:middle, b) # => ((-5.0 -> 5.0), (-5.0 -> 5.0))
a.align_y_of(:end, b)    # => ((-5.0 -> 5.0), (40.0 -> 50.0))

# `a.align_x_of(:middle, b)` と `a.align_y_of(:middle, b)` のショートカット:

a.align_middle_x_of(b)    # => ((-5.0 -> 5.0), (-5.0 -> 5.0))
a.align_middle_y_of(b)    # => ((-5.0 -> 5.0), (-5.0 -> 5.0))

# a を b の**内側**の上下左右の辺にくっつける

a.mid_top_of(b)    # => ((-5.0 -> 5.0), (40.0 -> 50.0))
a.mid_bottom_of(b) # => ((-5.0 -> 5.0), (-50.0 -> -40.0))
a.mid_left_of(b)   # => ((-50.0 -> -40.0), (-5.0 -> 5.0))
a.mid_right_of(b)  # => ((40.0 -> 50.0), (-5.0 -> 5.0))

# a を b の中心に配置する

a.middle_of(b)     # => ((-5.0 -> 5.0), (-5.0 -> 5.0))

#+title2: 中央で十字に区切る

a = Rect.from_x_y_w_h(200.0, 300.0, 10.0, 10.0)

# 座標

b = a.subdivision_ranges
b.x_a                      # => (195.0 -> 200.0)
b.x_b                      # => (200.0 -> 205.0)
b.y_a                      # => (295.0 -> 300.0)
b.y_b                      # => (300.0 -> 305.0)

# 領域

a.subdivisions[0]               # => ((195.0 -> 200.0), (295.0 -> 300.0))
a.subdivisions[1]               # => ((200.0 -> 205.0), (295.0 -> 300.0))
a.subdivisions[2]               # => ((195.0 -> 200.0), (300.0 -> 305.0))
a.subdivisions[3]               # => ((200.0 -> 205.0), (300.0 -> 305.0))

#+title2: 内部の方向を正にする

a = Rect.new(Range2.new(1.0, -1.0), Range2.new(1.0, -1.0))
a                          # => ((1.0 -> -1.0), (1.0 -> -1.0))
a.absolute               # => ((-1.0 -> 1.0), (-1.0 -> 1.0))

# 同じ領域でも右下から左上の向きになっている場合がある。それを左上から右下方向に直す。

#+title2: AND 領域

a = Rect.from_x_y_w_h(100.0, 100.0, 100.0, 100.0)
b = Rect.from_x_y_w_h(150.0, 150.0, 100.0, 100.0)
a.overlap(b)               # => ((100.0 -> 150.0), (100.0 -> 150.0))

#+title2: OR 領域

a = Rect.from_x_y_w_h(100.0, 100.0, 100.0, 100.0)
b = Rect.from_x_y_w_h(150.0, 150.0, 100.0, 100.0)
a.max(b)                  # => ((50.0 -> 200.0), (50.0 -> 200.0))

#+title2: x y をそれぞれ移動

a = Rect.from_wh(V[100.0, 100.0])
a                          # => ((-50.0 -> 50.0), (-50.0 -> 50.0))
a.shift_x(25.0)           # => ((-25.0 -> 75.0), (-50.0 -> 50.0))
a.shift_y(25.0)           # => ((-50.0 -> 50.0), (-25.0 -> 75.0))

#+warn: x, y の一方だけをずらすため元の形が崩れる

#+title2: 相手のどこかに移動する

a = Rect.from_wh(V[10.0, 10.0])
b = Rect.from_wh(V[100.0, 100.0])

#+title5: 辺の外側 (below: 下, above: 上)

a.left_of(b)             # => ((-60.0 -> -50.0), (-5.0 -> 5.0))
a.right_of(b)            # => ((50.0 -> 60.0), (-5.0 -> 5.0))
a.below(b)               # => ((-5.0 -> 5.0), (-60.0 -> -50.0))
a.above(b)               # => ((-5.0 -> 5.0), (50.0 -> 60.0))

#+title5: 辺の内側

a.align_left_of(b)             # => ((-50.0 -> -40.0), (-5.0 -> 5.0))
a.align_right_of(b)            # => ((40.0 -> 50.0), (-5.0 -> 5.0))
a.align_bottom_of(b)           # => ((-5.0 -> 5.0), (-50.0 -> -40.0))
a.align_top_of(b)              # => ((-5.0 -> 5.0), (40.0 -> 50.0))

#+title5: 角の内側

a.top_left_of(b)         # => ((-50.0 -> -40.0), (40.0 -> 50.0))
a.top_right_of(b)        # => ((40.0 -> 50.0), (40.0 -> 50.0))
a.bottom_left_of(b)      # => ((-50.0 -> -40.0), (-50.0 -> -40.0))
a.bottom_right_of(b)     # => ((40.0 -> 50.0), (-50.0 -> -40.0))

#+title2: 指定の座標を含むように近い方の辺を広げる

a = Rect.from_wh(V[10.0, 10.0])
a.stretch_to_point(V[6.0, 6.0]) # => ((-5.0 -> 6.0), (-5.0 -> 6.0))

#+warn: 比率が壊れる

#+title2: 指定の座標にいちばん近い角の名前を返す

a = Rect.from_wh(V[10.0, 10.0])
a.closest_corner(V[1.0, 1.0])   # => :top_right
a.closest_corner(V[-1.0, -1.0]) # => :bottom_left
a.closest_corner(V[-1.0, 1.0])  # => :top_left
a.closest_corner(V[1.0, -1.0])  # => :bottom_right

#+title2: 角の座標を返す

a = Rect.from_wh(V[10.0, 10.0])
a.corners   # => [(-5.0, 5.0), (5.0, 5.0), (5.0, -5.0), (-5.0, -5.0)]

#+title2: 左上から右下に切ってできる2つの三角形を返す

a = Rect.from_wh(V[10.0, 10.0])
a.triangles[0]   # => [(-5.0, 5.0), (5.0, 5.0), (5.0, -5.0)]
a.triangles[1]   # => [(-5.0, 5.0), (5.0, -5.0), (-5.0, -5.0)]

#+title2: x, y をまとめて移動

a = Rect.from_wh(V[100.0, 100.0])
a.shift(V[10.0, 10.0])      # => ((-40.0 -> 60.0), (-40.0 -> 60.0))

#+title2: 指定の座標が含まれるか？

a = Rect.from_wh(V[100.0, 100.0])
a.contains?(V[0.0, 50.0])       # => true
a.contains?(V[0.0, 51.0])       # => false

#+title2: 指定の座標が含まれるまで近い方を伸ばす

a = Rect.from_wh(V[2.0, 2.0])
a.stretch_to(V[5.0, 5.0])     # => ((-1.0 -> 5.0), (-1.0 -> 5.0))

#+title2: 領域を内側に縮小する

a = Rect.from_wh(V[100.0, 100.0])
a.pad_left(10.0)   # => ((-40.0 -> 50.0), (-50.0 -> 50.0))
a.pad_right(10.0)  # => ((-50.0 -> 40.0), (-50.0 -> 50.0))
a.pad_bottom(10.0) # => ((-50.0 -> 50.0), (-40.0 -> 50.0))
a.pad_top(10.0)    # => ((-50.0 -> 50.0), (-50.0 -> 40.0))
a.pad(10.0)        # => ((-40.0 -> 40.0), (-40.0 -> 40.0))
b = Rect.new(Range2.new(10.0, 10.0), Range2.new(10.0, 10.0))
a.padding(b)       # => ((-40.0 -> 40.0), (-40.0 -> 40.0))

#+title2: 相対的な範囲を返す

a = Rect.from_wh(V[10.0, 10.0])
a                        # => ((-5.0 -> 5.0), (-5.0 -> 5.0))
a.relative_to_x(10.0)    # => ((-15.0 -> -5.0), (-5.0 -> 5.0))
a.relative_to_y(10.0)    # => ((-5.0 -> 5.0), (-15.0 -> -5.0))
a.relative_to(V[10.0, 10.0])    # => ((-15.0 -> -5.0), (-15.0 -> -5.0))

#+title2: 反転

a = Rect.from_wh(V[2.0, 2.0])
a               # => ((-1.0 -> 1.0), (-1.0 -> 1.0))
a.invert_x    # => ((1.0 -> -1.0), (-1.0 -> 1.0))
a.invert_y    # => ((-1.0 -> 1.0), (1.0 -> -1.0))
