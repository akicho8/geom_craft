#+hidden: true
require "./setup"

#+title2: 早見表

# | 種類   | 意味                     | Methods              | 同類・備考                     |
# |--------+--------------------------+----------------------+--------------------------------|
# | 生成   | pos ± (len / 2)         | from_pos_and_len     | 推奨                           |
# | 生成   | start..end               | new(start, end)      |                                |
# | 参照   | 左, 右, 中央             | start / end / middle |                                |
# | 参照   | 強さ (end - start)       | magnitude            |                                |
# | 参照   | 長さ (強さの絶対値)      | length               |                                |
# | 向き   | 向き                     | direction            | -1, 0, 1 を返す                |
# | 向き   | 相手と同じ向きか？       | same_direction?(o)   |                                |
# | 向き   | 反転                     | invert               |                                |
# | 向き   | 「←」なら「→」にする   | absolute             |                                |
# | 対領域 | OR                       | a.max(o)             |                                |
# | 対領域 | OR (向きを維持する)      | a.max_directed(o)    |                                |
# | 対領域 | AND                      | a.overlap(o)         |                                |
# | 移動   | 相手の軸に揃える         | a.align_start_of(o)  | align_end_of / align_middle_of |
# | 移動   | 相手の軸の ? に揃える    | a.align_to(?, o)     |                                |
# | 移動   | 相手の隣に並べる         | a.align_after(o)     | a.align_before(o)              |
# | 移動   | v だけ移動する           | shift(v)             |                                |
# | 変形   | 縮小                     | pad(v)               | pad_start / pad_end / pad_ends |
# | 変形   | v に近い方の端を広げる   | stretch_to_value(v)  |                                |
# | その他 | 線形補完                 | a.lerp(v)            | a.map_value(v, o)              |
# | その他 | 領域に含まれるか？       | a.contains?(v)       |                                |
# | その他 | 相手を補正する           | clamp_value(v)       | v.clamp(range) に類似          |
# | その他 | v に近い方の Edge を返す | closest_edge(v)      |                                |
# | その他 | 小数補正                 | round                | floor / ceil / truncate        |

#+title2: 特徴

# - Range クラスとは根本的に考え方が異なる
#   - 単に start と end の位置を持つだけ
#   - `start > end` の関係になることもある
#   - 終端を必ず含む
# - 値オブジェクト風
#   - start end は外部から更新できるものの破壊的メソッドはない

#+title2: コンストラクタ

#+title4: 基本

Range2.new(1, 2)  # => (1 -> 2)

#+title4: pos を中心に半径 len / 2 の幅とする

Range2::from_pos_and_len(100.0, 10.0)  # => (95.0 -> 105.0)

#+title2: それぞれの値

Range2.new(100.0, 200.0).start     # => 100.0
Range2.new(100.0, 200.0).middle  # => 150.0
Range2.new(100.0, 200.0).end       # => 200.0

#+title2: ベクトルの強さと長さ

#+title4: 強さ (end - start)

Range2.new(100, -200).magnitude  # => -300

#+title4: 長さ (強さの絶対値)

Range2.new(100, -200).length  # => 300

#+title2: 小数の補正

Range2.new(0.4, 0.5).round    # => (0 -> 1)
Range2.new(0.4, 0.5).floor    # => (0 -> 0)
Range2.new(0.4, 0.5).ceil     # => (1 -> 1)
Range2.new(0.4, 0.5).truncate # => (0 -> 0)

#+title2: 範囲

#+title4: OR (向きを破壊する)

a = Range2.new(5.0, 3.0)
b = Range2.new(4.0, 6.0)
a.max(b)  # => (3.0 -> 6.0)

#+title4: OR (向きを維持する)

a = Range2.new(5.0, 3.0)
b = Range2.new(4.0, 6.0)
a.max_directed(b)  # => (6.0 -> 3.0)

# a が右向きなら max と同じだが左向きなら max の invert になる。

#+title4: AND (向きを破壊する)

a = Range2.new(5.0, 3.0)
b = Range2.new(4.0, 6.0)
a.overlap(b)  # => (4.0 -> 5.0)

#+title2: 向き

#+title4: 現在の向きを返す

Range2.new(0, 10).direction   # => 1.0
Range2.new(10, 0).direction   # => -1.0
Range2.new(10, 10).direction  # => 0.0

#+title4: 向きが同じか？

a = Range2.new(1, 2)
b = Range2.new(3, 4)
a.same_direction?(b)  # => true

#+title4: 向きを反転する

Range2.new(0, 100).invert  # => (100 -> 0)

#+title4: 正の向きにする

Range2.new(10, 0).absolute  # => (0 -> 10)

# `start > end` なら invert する。

#+title2: スケーリング

a = Range2.new(0.0, 1.0)
b = Range2.new(0.0, 100.0)
a.map_value(0.9, b)  # => 90.0

# a の 0.9 は b では 90 になる。

# 元の範囲が 0..1 の場合 lerp 使うと簡潔に書ける。

b.lerp(0.9)  # => 90.0

#+title2: 指定の軸で整列する

#+title4: 相手の左端に揃える

a = Range2.new(0, 100)
b = Range2.new(50, 100)
a.align_start_of(b)  # => (50 -> 150)

#+title4: 相手の右端に揃える

a = Range2.new(0, 50)
b = Range2.new(0, 100)
a.align_end_of(b)  # => (50 -> 100)

#+title4: 相手の中央に揃える

a = Range2.new(0.0, 50.0)
b = Range2.new(0.0, 100.0)
a.align_middle_of(b)  # => (25.0 -> 75.0)

#+title4: 相手のどこかに揃える

a = Range2.new(0.0, 5.0)
b = Range2.new(10.0, 20.0)
a.align_to(:start, b)   # => (10.0 -> 15.0)
a.align_to(:end, b)     # => (15.0 -> 20.0)
a.align_to(:middle, b)  # => (12.5 -> 17.5)

#+title2: 横に並べる

#+title4: 相手の左隣り並べる

a = Range2.new(0.0, 5.0)
b = Range2.new(0.0, 10.0)
a.align_after(b)  # => (10.0 -> 15.0)

#+title4: 相手の右隣り並べる

a = Range2.new(0.0, 5.0)
b = Range2.new(0.0, 0.0)
a.align_before(b)  # => (-5.0 -> 0.0)

#+title2: Edge を寄せる (サイズが変わる)

#+title4: 左端を内側に寄せる

Range2.new(10, 0).pad_start(3)  # => (7 -> 0)

#+title4: 右端を内側に寄せる

Range2.new(10, 0).pad_end(3)  # => (10 -> 3)

#+title4: 両端を内側に寄せる

Range2.new(10, 0).pad(3)  # => (7 -> 3)

#+title4: 両端を内側に寄せる (個別指定)

Range2.new(10, 0).pad_ends(3, 4)  # => (7 -> 4)

#+title2: この範囲に含むか？

Range2.new(1, 2).contains?(2)  # => true

#+title2: 対象を補正する

Range2.new(10, 0).clamp_value(-1)  # => 0
Range2.new(10, 0).clamp_value(11)  # => 10

#+title2: ずらす (サイズ不変)

Range2.new(2, 3).shift(10)  # => (12 -> 13)

#+title2: 近い方の端を引き伸ばす

Range2.new(10, 20).stretch_to_value(5)   # => (5 -> 20)
Range2.new(10, 20).stretch_to_value(25)  # => (10 -> 25)

# 範囲内を指定した場合は何も変化しない。

Range2.new(10, 20).stretch_to_value(15)  # => (10 -> 20)

#+title2: 値に近い方の Edge を返す

Range2.new(0.0, 10.0).closest_edge(4.0)  # => :start
Range2.new(0.0, 10.0).closest_edge(6.0)  # => :end
