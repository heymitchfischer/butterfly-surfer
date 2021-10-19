require 'gosu'

# To Do: Make sure objects can't possibly exit the space
# Restrict stars
# Variable time steps
# Make them fling like crazy
# Maybe a collision doesn't get you out-- losing the balls does? Or losing the butterfly?

class Point
  COLOR = Gosu::Color::rgba(255, 255, 255, 255)

  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def update
    return @y += 1 if @y <= 50
    return @y -= 1 if @y >= 550
    @y += [-1, 1].sample
  end

  def draw
    Gosu.draw_line(x, y, COLOR, x + 1, y + 1, COLOR, 0)
  end
end

# class PlayerPoint < Point
#   COLOR = Gosu::Color::rgba(0, 255, 0, 255)

#   attr_reader :window

#   def initialize(x, y, window)
#     super(x, y)
#     @window = window
#   end

#   def update
#     if window.button_down?(Gosu::KbUp)
#       @y -= 1
#     elsif window.button_down?(Gosu::KbRight)
#       @x += 1
#     elsif window.button_down?(Gosu::KbDown)
#       @y += 1
#     elsif window.button_down?(Gosu::KbLeft)
#       @x -= 1
#     end
#   end
# end

class Butterfly
  ACCELERATION = 0.4
  FRICTION = 0.9

  attr_reader :x, :y, :window

  def initialize(x, y, window)
    @x = x
    @y = y
    @velocity_x = 0
    @velocity_y = 0
    @window = window
    @body_image = Gosu::Image.new('butterfly.png')
  end

  def draw
    @body_image.draw_rot(x, y, 0, 0, 0.5, 0.5, 0.5, 0.5)
  end

  def update
    accelerate_up if window.button_down?(Gosu::KbUp)
    accelerate_right if window.button_down?(Gosu::KbRight)
    accelerate_down if window.button_down?(Gosu::KbDown)
    accelerate_left if window.button_down?(Gosu::KbLeft)

    @x += @velocity_x
    @y += @velocity_y
    @velocity_x *= FRICTION
    @velocity_y *= FRICTION

    if @x >= 400
      @velocity_x -= (1000 / (700.0 - @x)**2)
    else
      @velocity_x += (1000 / (100.0 - @x)**2)
    end

    if @y >= 300
      @velocity_y -= (1000 / (550.0 - @y)**2)
    else
      @velocity_y += (1000 / (50.0 - @y)**2)
    end

    # p Math.sqrt((@x - 400.0)**2 + (@y - 300.0)) - 250.0

    # p 'x is ' + ((x - 400.0) / 200).to_s
    # p 'y is ' + ((y - 300.0) / 200).to_s
  end

  # def move
    # @x += @velocity_x
    # @y += @velocity_y
    # @velocity_x *= FRICTION
    # @velocity_y *= FRICTION

    # if @x > @window.width - @radius
    #   @velocity_x = 0
    #   @x = @window.width - @radius
    # end

    # if @x < @radius
    #   @velocity_x = 0
    #   @x = @radius
    # end

    # if @y > @window.height - @radius
    #   @velocity_y = 0
    #   @y = @window.height - @radius
    # end
  # end

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
    @velocity_x += val*10 if coordinate == 0
    @velocity_y += val*10 if coordinate == 1
  end
end

class Body
  attr_reader :x, :y, :mass, :color

  def initialize(x, y, mass, color)
    @x = x
    @y = y
    @mass = mass
    @color = color
  end

  def update
  end

  def draw
    Gosu.draw_quad(x, y, color, x + mass, y, color, x + mass, y + mass, color, x, y + mass, color, 0)
  end
end

class ButterflySurfer < Gosu::Window
  GRAVITATIONAL_CONSTANT = 6.67408 * (10**-11)
  AVERAGE_DENSITY = 1410
  COLOR = Gosu::Color::rgba(255, 0, 0, 255)

  attr_accessor :state, :initial_conditions, :butterfly

  def initialize
    super(800,600)
    self.caption = 'Butterfly Surfer'
    @sun = Body.new(300, 400, 50, Gosu::Color::rgba(255, 0, 0, 255))
    @earth = Body.new(500, 300, 10, Gosu::Color::rgba(0, 0, 255, 255))
    @initial_conditions = { bodies: 3 }
    @body_image = Gosu::Image.new('body.png')
    @butterfly = Butterfly.new(400, 300, self)
    @ui = Gosu::Image.new('ui.png')
    @state = {
      u: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      # masses: {
      #   q: 0.2, # Current mass ratio m2 / m1
      #   m1: 50,
      #   m2: 10, # Will be set to q
      #   m12: 60 # Will be set to m1 + m2
      # },
      # eccentricity: 0.7,
      # positions: [
      #   {
      #     x: 300,
      #     y: 400
      #   },
      #   {
      #     x: 500,
      #     y: 300
      #   }
      # ]
    }
    change_initial_conditions
    reset_state_to_initial_conditions
    # state[:u][3] = initialVelocity
  end

  def update
    butterfly.update
    update_position(update_interval / 1000)
    # p state[:u]
    points.each { |point| point.update }
  end

  def draw
    # @sun.draw
    # @earth.draw
    points.each { |point| point.draw }
    # @ui.draw(0, 0, 1)
    butterfly.draw

    initial_conditions[:bodies].times do |iBody|
      body_start = iBody * 4 # Starting index for current body in the u array

      x = ((state[:u][body_start + 0]*200) + 400)
      y = ((state[:u][body_start + 1]*200) + 300)
      @body_image.draw_rot(x, y, 0, 0, 0.5, 0.5, 2, 2)
      # draw_quad(x, y, COLOR, x + 30, y, COLOR, x + 30, y + 30, COLOR, x, y + 30, COLOR, 0)
    end
  end

  # Calculate the derivatives of the system of ODEs that describe equation of motion of two bodies
  # def derivative
  #   du = Array.new(state[:u].length)

  #   # x and y coordinates
  #   r = state[:u].slice(0,2)

  #   # Distance between bodies
  #   rr = Math.sqrt(r[0]**2 + r[1]**2)

  #   (0..1).each do |i|
  #     du[i] = state[:u][i + 2]
  #     p state[:masses][:q]
  #     p rr
  #     du[i + 2] = -(1 + state[:masses][:q]) * r[i] / (rr**3)
  #   end

  #   du
  # end

  # def initialVelocity
  #   Math.sqrt((1 + state[:masses][:q]) * (1 + state[:eccentricity]))
  # end

  def rungeKutta(h, u)
    # h: timestep
    # u: variables
    # derivative: function that calculates the derivatives
    a = [h/2, h/2, h, 0]
    b = [h/6, h/3, h/3, h/6]
    u0 = []
    ut = []
    dimension = u.length

    dimension.times do |i|
      u0.push(u[i])
      ut.push(0)
    end

    4.times do |j|
      du = derivative

      dimension.times do |i|
        u[i] = u0[i] + a[j]*du[i]
        ut[i] = ut[i] + b[j]*du[i]
      end
    end

    dimension.times do |i|
      u[i] = u0[i] + ut[i]
    end
  end

  # Calculate the radius of the body (in meters) based on its mass.
  # def calculateRadiusFromMass(mass, density)
  #   (3/4 * mass / (Math::PI * density))**(1/3)
  # end

  # # Returns the diameters of three bodies in meters
  # def calculateDiameters
  #   diameters = []

  #   # Loop through the bodies
  #   initial_conditions[:bodies].times do |iBody|
  #     if initial_conditions[:densities] && initial_conditions[:densities].length >= initial_conditions[:bodies] - 1
  #       density = initial_conditions[:densities][iBody]
  #     else
  #       density = AVERAGE_DENSITY
  #     end

  #     diameters.push(2 * calculateRadiusFromMass(initial_conditions[:masses][iBody], density))
  #   end

  #   diameters
  # end

  def calculate_center_of_mass_velocity
    center_of_mass_velocity = { x: 0, y: 0 }
    sum_of_masses = 0

    # Loop through the bodies
    initial_conditions[:bodies].times do |iBody|
      body_start = iBody * 4 # Starting index for current body in the u array
      center_of_mass_velocity[:x] += initial_conditions[:masses][iBody] * state[:u][body_start + 2]
      center_of_mass_velocity[:y] += initial_conditions[:masses][iBody] * state[:u][body_start + 3]
      sum_of_masses += initial_conditions[:masses][iBody]
    end

    center_of_mass_velocity[:x] /= sum_of_masses
    center_of_mass_velocity[:y] /= sum_of_masses

    center_of_mass_velocity
  end

  def calculate_center_of_mass
    center_of_mass = { x: 0, y: 0 }
    sum_of_masses = 0

    # Loop through the bodies
    initial_conditions[:bodies].times do |iBody|
      body_start = iBody * 4 # Starting index for current body in the u array
      center_of_mass[:x] += initial_conditions[:masses][iBody] * state[:u][body_start + 0]
      center_of_mass[:y] += initial_conditions[:masses][iBody] * state[:u][body_start + 1]
      sum_of_masses += initial_conditions[:masses][iBody]
    end

    center_of_mass[:x] /= sum_of_masses
    center_of_mass[:y] /= sum_of_masses

    center_of_mass
  end

  def reset_state_to_initial_conditions
    # Loop through the bodies
    initial_conditions[:bodies].times do |iBody|
      body_start = iBody * 4 # Starting index for current body in the u array

      position = initial_conditions[:positions][iBody]
      state[:u][body_start + 0] = position[:r] * Math.cos(position[:theta]) # x
      state[:u][body_start + 1] = position[:r] * Math.sin(position[:theta]) # y

      # state[:u][body_start + 0] = position[:x] # x
      # state[:u][body_start + 1] = position[:y] # y

      velocity = initial_conditions[:velocities][iBody]
      state[:u][body_start + 2] = velocity[:r] * Math.cos(velocity[:theta]) # velocity x
      state[:u][body_start + 3] = velocity[:r] * Math.sin(velocity[:theta]) # velocity y
    end

    center_of_mass_velocity = calculate_center_of_mass_velocity
    center_of_mass = calculate_center_of_mass
    @center_of_mass = center_of_mass

    # Correct the velocities and positions of the bodies
    # to make the center of mass motionless at the middle of the screen
    # initial_conditions[:bodies].times do |iBody|
    #   body_start = iBody * 4 # Starting index for current body in the u array
    #   state[:u][body_start + 0] -= center_of_mass[:x]
    #   state[:u][body_start + 1] -= center_of_mass[:y]
    #   state[:u][body_start + 2] -= center_of_mass_velocity[:x]
    #   state[:u][body_start + 3] -= center_of_mass_velocity[:y]
    # end
  end

  # Calculates the acceleration of the body 'iFromBody'
  # due to gravity from other bodies,
  # using Newton's law of gravitation.
  #   iFromBody: the index of body. 0 is first body, 1 is second body.
  #   coordinate: 0 for x coordinate, 1 for y coordinate
  def acceleration(iFromBody, coordinate)
    result = 0
    iFromBodyStart = iFromBody * 4 # Starting index for the body in the u array

    # Loop through the bodies
    initial_conditions[:bodies].times do |iToBody|
      next if iFromBody == iToBody

      iToBodyStart = iToBody * 4 # Starting index for the body in the u array

      # Distance between the two bodies
      distanceX = state[:u][iToBodyStart + 0] - state[:u][iFromBodyStart + 0]
      distanceY = state[:u][iToBodyStart + 1] - state[:u][iFromBodyStart + 1]

      distance = Math.sqrt((distanceX**2) + (distanceY**2))
      gravitational_constant = 1

      # Add some friction
      # distanceX = state[:u][iToBodyStart + 0] - @center_of_mass[:x]
      # distanceY = state[:u][iToBodyStart + 1] - @center_of_mass[:y]
      # distance_from_center = Math.sqrt((distanceX**2) + (distanceY**2))

      # p distance_from_center * 0.01

      if initial_conditions[:dimensionless] != true
        gravitational_constant = GRAVITATIONAL_CONSTANT
      end

      result += (gravitational_constant * initial_conditions[:masses][iToBody] * (state[:u][iToBodyStart + coordinate] - state[:u][iFromBodyStart + coordinate]) / (distance**3))
    end

    # Add butterfly effect - START
    b_coords = [((butterfly.x - 400.0) / 200), ((butterfly.y - 300.0) / 200)]
    distanceX = b_coords[0] - state[:u][iFromBodyStart + 0]
    distanceY = b_coords[1] - state[:u][iFromBodyStart + 1]
    distance = Math.sqrt((distanceX**2) + (distanceY**2))

    if distance.nonzero?
      gravitational_constant = 1

      result += (gravitational_constant * 0.0001 * (b_coords[coordinate] - state[:u][iFromBodyStart + coordinate]) / (distance**3))

      butterfly.apply_gravity((gravitational_constant * 0.00001 * (state[:u][iFromBodyStart + coordinate] - b_coords[coordinate]) / (distance**3)), coordinate)
    end
    # END

    result
  end

  def derivative
    du = Array.new(initial_conditions[:bodies] * 4)

    # Loop through the bodies
    initial_conditions[:bodies].times do |iBody|
      # Starting index for current body in the u array
      body_start = iBody * 4

      du[body_start + 0] = state[:u][body_start + 0 + 2] # Velocity x
      du[body_start + 1] = state[:u][body_start + 0 + 3] # Velocity y
      du[body_start + 2] = acceleration(iBody, 0) # Acceleration x
      du[body_start + 3] = acceleration(iBody, 1) # Acceleration y

      # Add wall effect - START
      # x = ((state[:u][body_start + 0]*200) + 400)
      # y = ((state[:u][body_start + 1]*200) + 300)
      # if x >= 400
      #   du[body_start + 2] -= (100 / (700.0 - x)**2)
      # else
      #   du[body_start + 2] += (100 / (100.0 - x)**2)
      # end

      # if y >= 300
      #   du[body_start + 3] -= (100 / (550.0 - y)**2)
      # else
      #   du[body_start + 3] += (100 / (50.0 - y)**2)
      # end
      # END
    end

    du
  end

  def update_position(timestep)
    rungeKutta(timestep, state[:u])
  end


  # def calculateNewPositions
  #   # Loop through the bodies
  #   initial_conditions[:bodies].times do |iBody|
  #     body_start = iBody * 4 # Starting index for current body in the u array

  #     state[:positions][iBody].x = state[:u][body_start + 0] + 400
  #     state[:positions][iBody].y = state[:u][body_start + 1] + 400
  #   end
  # end

  # Returns the largest distance of an object from the center based on initial considitions
  # def largestDistanceMeters
  #   result = 0

  #   # Loop through the bodies
  #   initial_conditions[:bodies].times do |iBody|
  #     position = initial_conditions[:positions][iBody]

  #     if result < position[:r]
  #       result = position[:r]
  #     end
  #   end

  #   result
  # end

  def change_initial_conditions
    vigure8Position = {x: 0.97000436, y: -0.24308753}
    vigure8Velocity = {x: -0.93240737, y: -0.86473146}

    initial_conditions[:dimensionless] = true
    initial_conditions[:masses] = [1, 1, 1]
    initial_conditions[:positions] = [polar_from_cartesian(vigure8Position),
                                      polar_from_cartesian({x: -vigure8Position[:x], y: -vigure8Position[:y]}),
                                      polar_from_cartesian({x: 0, y: 0})]
    initial_conditions[:velocities] = [polar_from_cartesian({x: -vigure8Velocity[:x] / 2, y: -vigure8Velocity[:y]/2}),
                                       polar_from_cartesian({x: -vigure8Velocity[:x] / 2, y: -vigure8Velocity[:y]/2}),
                                       polar_from_cartesian(vigure8Velocity)]
    # initial_conditions[:positions] = [polar_from_cartesian({x: 1, y: 0}),
    #                                   polar_from_cartesian({x: 1, y: 0.75}),
    #                                   polar_from_cartesian({x: 0, y: 0})]
    # initial_conditions[:velocities] = [polar_from_cartesian({x: 0, y: 0}),
    #                                    polar_from_cartesian({x: 0, y: 0}),
    #                                    polar_from_cartesian({x: 0, y: 0})]
    # initial_conditions[:positions] = [{ r: 1, theta: 0, x: 10, y: 0 },
    #                                   { r: 1, theta: 2*Math::PI/3, x: 0, y: 7.5 },
    #                                   { r: 1, theta: 4*Math::PI/3, x: 0, y: 0  }]
    # initial_conditions[:velocities] = [{ r: 0.55, theta: Math::PI/2 },
    #                                    { r: 0.55, theta: 2*Math::PI/3 + Math::PI/2, },
    #                                    { r: 0.55, theta: 4*Math::PI/3 + Math::PI/2 }]
    # initial_conditions[:timeScaleFactor] = 1
    # initial_conditions[:massSlider] = conditions[:massSlider]
    # initial_conditions[:timeScaleFactorSlider] = conditions[:timeScaleFactorSlider]
    # initial_conditions[:densities] = conditions[:densities]
    # initial_conditions[:paleOrbitalPaths] = conditions[:paleOrbitalPaths]
  end

  def polar_from_cartesian(coordinates)
    if coordinates[:x] == 0
      angle = 0
    else
      angle = Math.atan2(coordinates[:y], coordinates[:x])
    end

    {
      r: Math.sqrt(coordinates[:x]**2 + coordinates[:y]**2),
      theta: angle
    }
  end

  def points
    @points ||= (100..700).to_a.map { |x| Point.new(x, rand(50..550)) }
  end
end

window = ButterflySurfer.new
window.show
