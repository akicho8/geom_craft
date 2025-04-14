require "geom_craft"

RandNorm = GeomCraft::RandNorm
V        = GeomCraft::Vec2
Rect     = GeomCraft::Rect
Range2   = GeomCraft::Range2

Kernel.module_eval do
  private
  def rand_norm(...)
    GeomCraft::RandNorm.call(...)
  end
end

if $0 == __FILE__
  rand_norm                     # => 0.2171834669473525
end
