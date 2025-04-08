require "./setup"

#+hidden: true
require "./setup"

#+title2: 短かく書けるようにする

# ```ruby
# V = Vec2
# ```

# 整数と同じぐらい手短に書きたいので、V = Vec2 として V を使いたい。

#+title2: クラスメソッド

#+title3: 生成する

V.new                        # => (0.0, 0.0)
V.new(3, 4)                  # => (3, 4)

# new は冗長なのであまり使いたくない。

#+title3: [] が使える

V[]                          # => (0.0, 0.0)
V[3, 4]                      # => (3, 4)

# 基本的に `[]` を使う。

#+title3: 要素には何でも入れられる

V[true, false]              # => (true, false)
V[3, 4]                     # => (3, 4)
V[3.0, 4.0]                 # => (3.0, 4.0)
V["Left", "Right"]          # => (Left, Right)

# といっても数値か論理値を想定している。
# 数値が整数なら浮動小数点に変換したりなどしない。
# でも整数が途中で浮動小数点になることはある。

#+title3: 同じ値で生成する

V.splat(3)                  # => (3, 3)

#+title3: 角度から生成する

v = V.from_angle(45.deg_to_rad) # => (0.7071067811865476, 0.7071067811865475)
v.angle.rad_to_deg.round        # => 45

#+title3: あらかじめ決まった値で生成する

V.zero                          # => (0.0, 0.0)
V.one                           # => (1.0, 1.0)
V.neg_one                       # => (-1.0, -1.0)

V.nan                           # => (NaN, NaN)

V.max                           # => (Infinity, Infinity)
V.min                           # => (-Infinity, -Infinity)

V.x                             # => (1.0, 0.0)
V.neg_x                         # => (-1.0, 0.0)
V.y                             # => (0.0, 1.0)
V.neg_y                         # => (0.0, -1.0)

V.right                         # => (1.0, 0.0)
V.left                          # => (-1.0, 0.0)
V.down                          # => (0.0, 1.0)
V.up                            # => (0.0, -1.0)

V.axes                          # => [(1.0, 0.0), (0.0, 1.0)]

#+title3: 乱数で生成する

V.rand         # => (0.45540195241887316, 0.8155600583050552)
V.rand(100)    # => (96, 65)

# 引数は Kernel.rand と同じ

#+title3: 正規分布で生成する

V.rand_norm                     # => (1.3316033319284861, -0.7085766966845889)
V.rand_norm(sigma: 2)           # => (2.5913164945497753, -0.3554689651945139)
V.rand_norm(mu: 100)            # => (101.35469833250185, 101.08830026901417)

# - sigma → 1σ区間の幅 (初期値: 1.0)
# - mu → 中心 (初期値: 0.0)

#+title2: インスタンスメソッド

#+title3: 配列化する

V[3, 4].to_a                    # => [3, 4]

# 次のメソッドたちは to_a に委譲している。

#+BEGIN_SRC
v = V.one

v.each                  # => #<Enumerator: [1.0, 1.0]:each>
v == v                  # => true
v.eql?(v)               # => true
v.hash                  # => -2591597074245692329
v <=> v                 # => 0
v.to_ary                # => [1.0, 1.0]
v[0]                    # => 1.0
#+END_SRC

#+title3: Enumerable 対応

V[true, true].all?              # => true
V[false, true].any?             # => true
V[false, false].none?           # => true
V.one.sum                       # => 2.0
V.one.count                     # => 2

#+title3: 文字列化する

V[3, 4].to_s                    # => "(3, 4)"

#+title3: 文字列化する (デバッグ用)

V[3, 4].inspect                 # => "(3, 4)"

# `[]` を使うと配列と区別がつかないため `()` を使う。

#+title3: Hash 化する

V[3, 4].to_h                    # => {x: 3, y: 4}
V[3, 4].to_h(prefix: "a")       # => {ax: 3, ay: 4}
V[3, 4].to_h(suffix: "1")       # => {x1: 3, y1: 4}

# suffix の指定で Ruby 2D のような座標をシンボルで書くタイプにも変換しやすくする。

#+hidden: true
# #+title3: 置き換える
# v = V[3, 4]
# v.object_id                     # => 60
# v.replace(V[7, 8])
# v                               # =>
# v.object_id                     # =>

# object_id は変わっていない。
# Value Object 化する場合は取る。

#+hidden: true
#   # def scale(s)
#   #   self * s
#   # end

#+title3: 各成分同士の最小・最大

V[3, 6].min(V[4, 5])            # => (3, 5)
V[3, 6].max(V[4, 5])            # => (4, 6)

#+title3: 指定の範囲内に入れる

V[1, 9].clamp(V[3, 3], V[4, 4])            # => (3, 4)

#+title3: 大きい方・小さい方の要素を得る

V[3, 4].min_element             # => 3
V[3, 4].max_element             # => 4

#+title3: 比較

v = V[3, 4]
v.cmpeq(v)          # => (true, true)
v.cmpne(v)          # => (false, false)
v.cmpge(v)          # => (true, true)
v.cmpgt(v)          # => (false, false)
v.cmple(v)          # => (true, true)
v.cmplt(v)          # => (false, false)

# 結果で条件分岐する場合はさらに `any?` `all?` `none?` などを呼ぶ。

#+title3: 絶対値

V[-3, -4].abs                  # => (3, 4)

#+title3: 符号のみを保持したベクトルを返す

V[3, -4].signum               # => (1, -1)
V[-3, 4].signum               # => (-1, 1)

V[3, -4].sign                 # => (1, -1)
V[-3, 4].sign                 # => (-1, 1)

#+title3: 符号のみをコピーする

V[-3, 6].copysign(V[7, -8])               # => (3, -6)

# コピーといっても破壊的ではない。

#+title3: 有限？

V[3, 4].finite?                # => true

#+title3: NaN か？

V.nan.nan?                      # => true

#+title3: NaN の要素だけ true なベクトルを返す

V[1.0, 0.0 / 0.0].nan_mask                 # => (false, true)

#+title3: 二乗したときの長さ

V[3, 4].length_squared          # => 25

#+title3: 長さ

V[3, 4].length                  # => 5.0

V[3, 4].norm                    # => 5.0
V[3, 4].mag                     # => 5.0
V[3, 4].magnitude               # => 5.0

# ライブラリによってメソッド名が異なるためいろんな alias を用意している。
# Ruby の Matrix の Vector にある r は半径と誤読するため alias にしない。

#+title3: 長さの逆数

V[3, 4].length_recip            # => 0.2

# これがあると割り算を掛け算に変換できる。

100 / V[3, 4].length             # => 20.0
100 * V[3, 4].length_recip       # => 20.0

#+title3: 対象との差分の長さの二乗

V[4, 5].distance_squared_to(V[1, 1]) # => 25

#+title3: 対象との差分の長さ

V[4, 5].distance_to(V[1, 1])       # => 5.0

#+title3: 正規化

V[3, 4].normalize               # => (0.6000000000000001, 0.8)
V[3, 4].normalize.length        # => 1.0

# 0ベクトルは正規化できない

V.zero.normalize rescue $!      # => RuntimeError

#+title3: 正規化できない場合は nil を返す版

V.zero.try_normalize        # => nil

#+title3: 正規化できない場合は zero を返す版

V.zero.normalize_or_zero    # => (0.0, 0.0)

#+title3: 正規化してあるか？

V[3, 4].normalized?             # => false
V[3, 4].normalize.normalized?   # => true

#+title3: 射影

a  = V[2.0, 5.0]
b  = V[6.0, 3.0]

# a から b への正射影

a.project_onto(b)               # => (3.6, 1.8)

# これは b を地面と考えたとき太陽視点での a の影または b を地面として垂直にジャンプした a の着地点に相当する。
# project_onto がやっていることは

# 1. 地面の方を正規化して内積を求めると影の長さが求まる
# 1. それを地面の方向に伸ばす(正規化した b だけスケールする)と位置が求まる

a.dot(b.normalize) * b.normalize         # => (3.6, 1.8)

# 射影先が正規化されていればその処理を省けるので専用のメソッドがある。

a.project_onto_normalized(b.normalize)   # => (3.6, 1.8)

# 射影できない場合は例外を出す

V.zero.project_onto(V.zero) rescue $! # => RuntimeError

#+title3: 垂直方向への射影

a.reject_from(b)                # => (-1.6, 3.2)

# これは b を地面と考えたときの真横から強い光を当てて壁にできる影または b を地面と考えたときのジャンプした a の高さに相当する。
# これは単に `a - 着地点(a から b への投射)` でも求まる。

a - a.project_onto(b)           # => (-1.6, 3.2)

# 上の射影と同様に地面が正規化されている版もある。

a.reject_from_normalized(b.normalize) # => (-1.6, 3.2)

#+title3: 小数部補正

V[3.4, 4.5].round               # => (3, 5)
V[3.4, 4.5].floor               # => (3, 4)
V[3.4, 4.5].ceil                # => (4, 5)
V[3.4, 4.5].truncate            # => (3, 4)
V[3.4, 4.5].trunc               # => (3, 4)

#+title3: 小数部のみ残す

V[3.4, 4.5].fract               # => (0.3999999999999999, 0.5)

#+title3: 指数関数

V[3, 4].exp                     # => (20.085536923187668, 54.598150033144236)
V[Math::E**3, Math::E**4]       # => (20.085536923187664, 54.59815003314423)

# Math::E を参照するより exp を使った方が精度が高いらしい

#+title3: べき乗

V[3, 4]**2                     # => (9, 16)
V[3, 4].pow(2)                 # => (9, 16)
V[3, 4].pow(2, 5)              # => (4, 1)

#+title3: 逆数

V[3, 4].recip                   # => (0.3333333333333333, 0.25)

# 逆数を使うと割り算を掛け算に変換できる。

V.splat(100.0) / V[3, 4]        # => (33.333333333333336, 25.0)
V.splat(100.0) * V[3, 4].recip  # => (33.33333333333333, 25.0)

# 掛け算にすると右辺・左辺を気しなくてよくなるので逆にして

V[3, 4].recip * V.splat(100.0)  # => (33.33333333333333, 25.0)

# と書ける。もし割り算だと左右を入れ替えると当然結果が変わってしまう。

V[3, 4] / V.splat(100.0)        # => (0.03, 0.04)

#+title3: 線形補間

V[3, 3].lerp(V[4, 4], 0.0) # => (3.0, 3.0)
V[3, 3].lerp(V[4, 4], 0.5) # => (3.5, 3.5)
V[3, 3].lerp(V[4, 4], 1.0) # => (4.0, 4.0)

# alias

V[3, 3].mix(V[4, 4], 0.5)  # => (3.5, 3.5)

#+title3: 誤差を許容した比較

V.zero.abs_diff_eq(V[0.0, 0.01], 0.00) # => false
V.zero.abs_diff_eq(V[0.0, 0.01], 0.01) # => true

#+title3: 長さ補正

V[3, 4].length                         # => 5.0

V[3, 4].clamp_length(6, 7)             # => (3.6, 4.8)
V[3, 4].clamp_length(6, 7).length      # => 6.0

V[3, 4].clamp_length_min(6)            # => (3.6, 4.8)
V[3, 4].clamp_length_min(6).length     # => 6.0

V[3, 4].clamp_length_max(4)            # => (2.4, 3.2)
V[3, 4].clamp_length_max(4).length     # => 4.0

# 長さを指定して new したいとき:

V.one.clamp_length_min(5)       # => (3.5355339059327373, 3.5355339059327373)

#+title3: 指定のベクトルの倍数の近い方に四捨五入で合わせる

V[5.0, 14.0].snapped(V[10.0, 10.0])        # => (10.0, 10.0)

#+title3: 2点間の角度差

a = V[2.0, 0.0]
b = V[1.0, 0.0]
b.angle_to(a)      # => 0.0
b.angle_between(a) # => 0.0
a.angle - b.angle  # => 0.0

#+title3: 自分から相手を見たときの角度

a = V[2.0, 0.0]
b = V[1.0, 0.0]
a.angle_to_point(b)  # => 3.141592653589793

# 両方を位置ベクトルと見なしたときの a から b 方向への角度を返す。

#+title3: 角度

V[2, 2].angle                   # => 0.7853981633974483

#+title3: 回転

v0 = V.from_angle(30.deg_to_rad) * 100

# 30度(長さ100)のベクトルを60度回転して90度になる例:

v1 = v0.rotate(60.deg_to_rad)
v1.round(2)                     # => (0.0, 100.0)
v1.angle.rad_to_deg.round       # => 90
v1.length                       # => 100.0

# rotate には方向ベクトルを渡してもよい。

v1 = v0.rotate(V.from_angle(60.deg_to_rad))
v1.round                        # => (0, 100)

# 回転される側の方向に角度を足して再度生成する方法もある。

v1 = V.from_angle(v0.angle + 60.deg_to_rad) * v0.length
v1.round(2)                     # => (0.0, 100.0)
v1.angle.rad_to_deg.round       # => 90
v1.length                       # => 100.0

# それを簡単にしたのが rotate_angle_add になる。

v1 = v0.rotate_angle_add(60.deg_to_rad)
v1.round(2)                     # => (0.0, 100.0)
v1.angle.rad_to_deg.round       # => 90
v1.length                       # => 100.0

# 後者は glam のメソッドにはなかったが glam の方法より速かったので入れてある。

#+title3: 内積

V[2, 3].dot(V[4, 5])            # => 23
V[2, 3].inner_product(V[4, 5])  # => 23
2 * 4 + 3 * 5                   # => 23

# - a.dot(b) → a.x * b.x + a.y * b.y
# - 底辺 = 斜辺.dot(地面.normalize)

#+title3: 外積

V[2, 3].cross(V[4, 5])          # => -2
V[2, 3].perp_dot(V[4, 5])       # => -2
V[2, 3].outer_product(V[4, 5])  # => -2
2 * 5 - 4 * 3                   # => -2

# - a.cross(b) → a.x * b.y - a.y * b.x
# - 対辺 = 地面.normalize.cross(斜辺)

#+title3: 法線

V[2, 3].perp                    # => (-3, 2)
V[2, 3].right90                 # => (-3, 2)

#+title3: 法線の逆向き

V[2, 3].left90                  # => (3, -2)

# left right の動作が画面下方向を正とする座標系に依存しているのがちょっと気持ち悪い。

#+title3: 壁ずり・反射・鏡像ベクトル

a = V[600.0, 340.0]
b = V[200.0,  60.0]
c = V[360.0,  52.0]
d = V[400.0, 200.0]
n = (b - a).perp.normalize # => (0.5734623443633283, -0.8192319205190405)
speed = d - c              # => (40.0, 148.0)
speed.slide(n)          # => (96.37583892617451, 67.46308724832214)
speed.bounce(n)         # => (152.75167785234902, -13.073825503355721)
speed.reflect(n)        # => (-152.75167785234902, 13.073825503355721)

# 引数には法線の正規化を渡す。

#+title3: 演算

v0 = V[2, 3]
v1 = V[4, 5]

# 演算子

v0 + v1                         # => (6, 8)
v0 - v1                         # => (-2, -2)
v0 * v1                         # => (8, 15)
v0 / v1                         # => (0, 0)
v0 % v1                         # => (2, 3)
-v0                             # => (-2, -3)
+v0                             # => (2, 3)

# メソッド版

v0.add(v1)                      # => (6, 8)
v0.sub(v1)                      # => (-2, -2)
v0.mul(v1)                      # => (8, 15)
v0.div(v1)                      # => (0, 0)
v0.fdiv(v1)                     # => (0.5, 0.6)
v0.ceildiv(v1)                  # => (1, 1)
v0.modulo(v1)                   # => (2, 3)
v0.neg                          # => (-2, -3)

# `/` と `div` と `fdiv` は数値に対する実行と同じで微妙に結果が異なる。

#+title3: 要素入れ替え

V.x.xy                          # => (1.0, 0.0)
V.x.yx                          # => (0.0, 1.0)
V.x.xx                          # => (1.0, 1.0)
V.x.yy                          # => (0.0, 0.0)

#+title3: 中央

v0 = V.one.clamp_length_min(5)
v0.length                       # => 5.0

v0.center.length                # => 2.5

v0.middle.length                # => 2.5

# alias として middle もある。

#+title3: 位置ベクトルと見なしたとき対象が含まれるか？

v0 = V[3, 4]
v1 = V[4, 5]
v0.cover?(v1)             # => false
v0.cover?(v1, padding: 1) # => true

# v0 の先端との当たり判定を行いたいときに用いる。

#+title3: 配列のようにソートできる

[V[3, 4], V[1, 2]].sort         # => [(1, 2), (3, 4)]

#+title3: 中身が似ていればハッシュキーは同じ

V[3, 4].hash                    # => -249668369487262050
V[3, 4].hash                    # => -249668369487262050
V[3, 4].eql?(V[3, 4])           # => true
h = { V[3, 4] => true }         # => {(3, 4) => true}
h[V[3, 4]]                      # => true
