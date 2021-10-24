class Body
  attr_accessor :x, :y, :x_accel, :y_accel
  attr_reader :mass, :window

  def initialize(window, opts = {})
    @window = window
    @x = opts[:x]
    @y = opts[:y]
    @x_accel = opts[:x_accel]
    @y_accel = opts[:y_accel]
    @mass = opts[:mass]
    @sun_sprites = Gosu::Image.load_tiles('sun.png', 32, 32)
    @frames_elapsed = 0
    @sprite_index = 0
  end

  def update
    @frames_elapsed += 1

    if @frames_elapsed == 8
      @frames_elapsed = 0
      @sprite_index = @sprite_index == 1 ? 0 : @sprite_index + 1
    end
  end

  def draw
    @sun_sprites[@sprite_index].draw_rot((x*200) + 400, (y*200) + 300, 1, 0, 0.5, 0.5, 2, 2)
  end

  def accelerate(coordinate, bodies, butterfly)
    result = 0

    bodies.each do |body|
      next if self == body

      distance_x = body.x - x
      distance_y = body.y - y

      distance = Math.sqrt((distance_x**2) + (distance_y**2))
      result += (1 * body.mass * (body.send(coordinate) - self.send(coordinate)) / (distance**3))
    end

    return result unless window.game_active

    # Add butterfly effect
    b_coords = {
      x: (butterfly.x - 400.0) / 200,
      y: (butterfly.y - 300.0) / 200
    }

    distance_x = b_coords[:x] - x
    distance_y = b_coords[:y] - y
    distance = Math.sqrt((distance_x**2) + (distance_y**2))

    window.score_modifier = 2 if distance < 0.75 && window.score_modifier < 2
    window.score_modifier = 3 if distance < 0.5 && window.score_modifier < 3
    window.score_modifier = 4 if distance < 0.25 && window.score_modifier < 4

    if distance.nonzero?
      result += (1 * 0.0055 * (b_coords[coordinate] - self.send(coordinate)) / (distance**3))

      butterfly.apply_gravity((1 * 0.00001 * (self.send(coordinate) - b_coords[coordinate]) / (distance**3)), coordinate)
    end

    result
  end

  def update_state(values)
    self.x = values[0]
    self.y = values[1]
    self.x_accel = values[2]
    self.y_accel = values[3]

    if (x*200) + 400 > 778
      self.x_accel = -1.0
      self.x = (778.0 - 400.0) / 200
    elsif (x*200) + 400 < 32
      self.x_accel = 1.0
      self.x = (32.0 - 400.0) / 200
    end

    if (y*200) + 300 > 578
      self.y_accel = -1.0
      self.y = (578.0 - 300.0) / 200
    elsif (y*200) + 300 < 32
      self.y_accel = 1.0
      self.y = (32.0 - 300.0) / 200
    end
  end
end
