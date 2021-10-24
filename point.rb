class Point
  COLOR = Gosu::Color::rgba(255, 255, 255, 255)

  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def update
    return @y += 1 if @y <= 0
    return @y -= 1 if @y >= 600
    @y += [-1, 1].sample
  end

  def draw
    Gosu.draw_line(x, y, COLOR, x + 1, y + 1, COLOR, 0)
  end
end
