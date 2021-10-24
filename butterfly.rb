class Butterfly
  ACCELERATION = 0.4
  FRICTION = 0.9

  attr_reader :x, :y, :window, :sprites
  attr_accessor :frames_elapsed, :sprite_index

  def initialize(x, y, window)
    @x = x
    @y = y
    @velocity_x = 0
    @velocity_y = 0
    @window = window
    @sprites = Gosu::Image.load_tiles('butterfly.png', 32, 32)
    @frames_elapsed = 0
    @sprite_index = 0
  end

  def draw
    @sprites[@sprite_index].draw_rot(x, y, 1, 0)

    @frames_elapsed += 1

    if @frames_elapsed == 8
      @frames_elapsed = 0
      @sprite_index = @sprite_index == 2 ? 0 : @sprite_index + 1
    end
  end

  def update
    accelerate_up if window.button_down?(Gosu::KbUp) || window.button_down?(Gosu::KbW)
    accelerate_right if window.button_down?(Gosu::KbRight) || window.button_down?(Gosu::KbD)
    accelerate_down if window.button_down?(Gosu::KbDown) || window.button_down?(Gosu::KbS)
    accelerate_left if window.button_down?(Gosu::KbLeft) || window.button_down?(Gosu::KbA)

    @x += @velocity_x
    @y += @velocity_y
    @velocity_x *= FRICTION
    @velocity_y *= FRICTION

    if @x >= 400
      @velocity_x -= (1000 / (800.0 - @x)**2)
    else
      @velocity_x += (1000 / (0.0 - @x)**2)
    end

    if @y >= 300
      @velocity_y -= (1000 / (600.0 - @y)**2)
    else
      @velocity_y += (1000 / (0.0 - @y)**2)
    end
  end

  def accelerate_up
    @velocity_y -= ACCELERATION
  end

  def accelerate_right
    @velocity_x += ACCELERATION
  end

  def accelerate_down
    @velocity_y += ACCELERATION
  end

  def accelerate_left
    @velocity_x -= ACCELERATION
  end

  def apply_gravity(val, coordinate)
    @velocity_x += val*10 if coordinate == :x
    @velocity_y += val*10 if coordinate == :y
  end
end
