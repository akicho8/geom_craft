if $0 == __FILE__
  $LOAD_PATH.unshift("..")
end

module GeomCraft
  # 普通は rand の実行回数が少ないこっちを使う
  # 平均(mean) で 標準偏差が 1.0 (7割が±1.0の範囲にあるという意味)
  class RandNorm
    class << self
      def call(...)
        @instance ||= new(...)
        @instance.call(...)
      end
    end

    def initialize(mu: 0.0, sigma: 1.0, random: Random.new)
      @mu = mu
      @sigma = sigma
      @random = random
    end

    def call(mu: @mu, sigma: @sigma, random: @random)
      if @next_value
        v = @next_value
        @next_value = nil
      else
        r1 = random.rand
        r2 = random.rand
        a = Math.sqrt(-2 * Math.log(r1))
        b = 2 * Math::PI * r2
        x = a * Math.cos(b)      # ここで1つ取れる
        y = a * Math.sin(b)      # まとめて2つ目も取れる
        @next_value = y          # 次に返すように取っておく
        v = x
      end
      mu + sigma * v
    end
  end
end

if $0 == __FILE__
  @rand_norm = GeomCraft::RandNorm.new
  def rnorm(...)
    @rand_norm.call(...)
  end

  n = 1000000
  list = n.times.collect { rnorm(mu: 70, sigma: 10) }

  # 配列から標準偏差の取得
  avg = list.sum.fdiv(n)
  sd = Math.sqrt(list.collect { |v| (v - avg)**2 }.sum.fdiv(n))
  sd # => 9.996427943190731

  # 1,2,3倍はそれぞれ 68.26% 95.44% 99.74% になるか？
  list.count { |v| (-(sd*1)..(sd*1)).include?(v - avg) }.fdiv(n) # => 0.682338
  list.count { |v| (-(sd*2)..(sd*2)).include?(v - avg) }.fdiv(n) # => 0.954698
  list.count { |v| (-(sd*3)..(sd*3)).include?(v - avg) }.fdiv(n) # => 0.997286
end
