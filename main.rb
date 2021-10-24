require 'gosu'
require_relative 'butterfly.rb'
require_relative 'point.rb'
require_relative 'body.rb'

# MAJOR REFACTOR NEEDED

class ButterflySurfer < Gosu::Window
  SELECTED_OPTION_COLOR = Gosu::Color::rgba(234, 242, 0, 255)
  UNSELECTED_OPTION_COLOR = Gosu::Color::rgba(255, 255, 255, 255)
  WHITE = Gosu::Color::rgba(255, 255, 255, 255)
  BLACK = Gosu::Color::rgba(0, 0, 0, 255)
  GAME_LENGTH = 60

  attr_accessor :menu_index, :game_active, :elapsed_time_start, :score, :game_duration, :score_modifier, :how_to_play_active, :end_game_menu_active, :game_over_message, :credits_active
  attr_reader :bodies, :butterfly, :big_font, :option_font, :main_menu_options, :post_game_menu_options, :main_menu_music, :game_music, :death_sound, :beep_sound

  def initialize
    super(800,600)
    self.fullscreen = false
    self.caption = 'Butterfly Surfer'
    @big_font = Gosu::Font.new(40, name: 'Courier New')
    @option_font = Gosu::Font.new(20, name: 'Courier New')

    @main_menu_options = [
      { text: 'Play', method: :start_game },
      { text: 'How To Play', method: :display_how_to_play },
      { text: 'Fullscreen', method: :toggle_fullscreen },
      { text: 'Credits', method: :display_credits },
      { text: 'Quit', method: :quit }
    ]

    @post_game_menu_options = [
      { text: 'Play Again', method: :start_game },
      { text: 'Main Menu', method: :exit_to_main_menu },
      { text: 'Quit', method: :quit }
    ]

    @menu_index = 0

    @game_music = Gosu::Song.new('sounds/through space.ogg')
    @main_menu_music = Gosu::Song.new('sounds/space.flac')
    @death_sound = Gosu::Sample.new('sounds/atari_boom3.wav')
    @beep_sound = Gosu::Sample.new('sounds/beep.wav')

    reset_game
  end

  def update
    if game_active
      tick_tock if Gosu.milliseconds - elapsed_time_start > 1000
      end_game if time_remaining <= 0
      butterfly.update
    end

    update_position(update_interval / 1000)
    points.each { |point| point.update }
    bodies.each { |body| body.update }

    if game_active
      bodies.each do |body|
        distance = Gosu.distance((body.x*200) + 400, (body.y*200) + 300, butterfly.x, butterfly.y)
        if distance < 32 + 15
          game_over
        end
      end
    end
  end

  def draw
    if game_active
      option_font.draw_text_rel(time_remaining, 775, 15, 2, 0.5, 0)
      option_font.draw_text("Score: #{score}", 12, 12, 2)
    else
      big_font.draw_markup_rel('<b>Butterfly Surfer</b>', 400, 80, 2, 0.5, 0)

      if end_game_menu_active
        draw_alert_window
        game_over_message ? draw_game_over_menu : draw_end_game_menu

        draw_options_y = 450
        post_game_menu_options.each_with_index do |option, i|
          color = menu_index == i ? SELECTED_OPTION_COLOR : UNSELECTED_OPTION_COLOR
          option_font.draw_text_rel(option[:text], 400, draw_options_y, 4, 0.5, 0, 1, 1, color)
          draw_options_y += 25
        end
      else
        if how_to_play_active
          draw_alert_window
          draw_how_to_play
        end

        if credits_active
          draw_credits_window
          draw_credits
        end

        draw_options_y = 450
        main_menu_options.each_with_index do |option, i|
          color = menu_index == i ? SELECTED_OPTION_COLOR : UNSELECTED_OPTION_COLOR
          option_font.draw_text_rel(option[:text], 400, draw_options_y, 2, 0.5, 0, 1, 1, color)
          draw_options_y += 25
        end
      end
    end

    points.each { |point| point.draw }
    bodies.each { |body| body.draw }
    butterfly.draw
  end

  def toggle_fullscreen
    self.fullscreen = !self.fullscreen?
    main_menu_options[2][:text] = self.fullscreen? ? 'Exit Fullscreen' : 'Fullscreen'
  end

  def draw_alert_window
    draw_quad(100, 300, BLACK, 700, 300, BLACK, 700, 575, BLACK, 100, 575, BLACK, 3)
    draw_line(100, 300, WHITE, 700, 300, WHITE, 4)
    draw_line(700, 300, WHITE, 700, 575, WHITE, 4)
    draw_line(700, 575, WHITE, 100, 575, WHITE, 4)
    draw_line(100, 575, WHITE, 100, 300, WHITE, 4)
  end

  def draw_credits_window
    draw_quad(50, 240, BLACK, 750, 240, BLACK, 750, 575, BLACK, 50, 575, BLACK, 3)
    draw_line(50, 240, WHITE, 750, 240, WHITE, 4)
    draw_line(750, 240, WHITE, 750, 575, WHITE, 4)
    draw_line(750, 575, WHITE, 50, 575, WHITE, 4)
    draw_line(50, 575, WHITE, 50, 240, WHITE, 4)
  end

  def draw_how_to_play
    option_font.draw_text_rel('DANCE WITH THE CELESTIAL BODIES', 400, 310, 4, 0.5, 0, 1, 1, WHITE)
    option_font.draw_text_rel('Earn points by staying alive. Maximize points per', 110, 350, 4, 0, 0, 1, 1, WHITE)
    option_font.draw_text_rel('second by gliding as close as possible to the bodies.', 110, 370, 4, 0, 0, 1, 1, WHITE)
    option_font.draw_text_rel('BUT BEWARE!', 400, 410, 4, 0.5, 0, 1, 1, WHITE)
    option_font.draw_text_rel('Your microscopic mass, although negligible, will have', 110, 450, 4, 0, 0, 1, 1, WHITE)
    option_font.draw_text_rel('an exponentially increasing impact on their fragile', 110, 470, 4, 0, 0, 1, 1, WHITE)
    option_font.draw_text_rel('equilibrium as you grow nearer. Disturb the natural', 110, 490, 4, 0, 0, 1, 1, WHITE)
    option_font.draw_text_rel('order at your own risk.', 110, 510, 4, 0, 0, 1, 1, WHITE)
    option_font.draw_text_rel('(Press any key to return)', 400, 550, 4, 0.5, 0, 1, 1, WHITE)
  end

  def draw_credits
    option_font.draw_text_rel('--CREDITS--', 400, 250, 4, 0.5, 0, 1, 1, WHITE)
    option_font.draw_text_rel('"Space (Orchestral)" by lasercheese', 400, 290, 4, 0.5, 0, 1, 1, WHITE)
    option_font.draw_text_rel('(https://soundcloud.com/laserost)', 400, 310, 4, 0.5, 0, 1, 1, WHITE)
    option_font.draw_text_rel('"Through Space" by maxstack', 400, 350, 4, 0.5, 0, 1, 1, WHITE)
    option_font.draw_text_rel('(https://maxstack.bandcamp.com)', 400, 370, 4, 0.5, 0, 1, 1, WHITE)
    option_font.draw_text_rel('"atari_boom3" by dklon', 400, 410, 4, 0.5, 0, 1, 1, WHITE)
    option_font.draw_text_rel('"Beep" by qubodup', 400, 450, 4, 0.5, 0, 1, 1, WHITE)
    option_font.draw_text_rel('"Programming a three-body problem in JavaScript" by Evgenii', 400, 490, 4, 0.5, 0, 1, 1, WHITE)
    option_font.draw_text_rel('(https://evgenii.com/blog/three-body-problem-simulator)', 400, 510, 4, 0.5, 0, 1, 1, WHITE)
    option_font.draw_text_rel('(Press any key to return)', 400, 550, 4, 0.5, 0, 1, 1, WHITE)
  end

  def button_down(key)
    if how_to_play_active
      beep_sound.play
      self.how_to_play_active = false
      return
    end

    if credits_active
      beep_sound.play
      self.credits_active = false
      return
    end

    if !game_active
      menu = end_game_menu_active ? post_game_menu_options : main_menu_options

      case key
      when Gosu::KbUp, Gosu::KbW
        beep_sound.play
        self.menu_index -= 1
        self.menu_index = menu.length - 1 if menu_index < 0
      when Gosu::KbDown, Gosu::KbS
        beep_sound.play
        self.menu_index += 1
        self.menu_index = 0 if menu_index > menu.length - 1
      when Gosu::KbReturn, Gosu::KbSpace
        beep_sound.play
        self.send(menu[menu_index][:method])
        self.menu_index = 0
      end
    end
  end

  def time_remaining
    GAME_LENGTH - game_duration
  end

  def tick_tock
    self.elapsed_time_start = Gosu.milliseconds
    self.game_duration += 1
    self.score += score_modifier
    self.score_modifier = 1
  end

  def reset_game
    main_menu_music.play(true)
    @game_active = false
    @butterfly = Butterfly.new(400, 150, self)
    @bodies = [
      Body.new(self, { x: 0.9700043599999999, y: -0.24308753, x_accel: 0.4662036849999999, y_accel: 0.43236573, mass: 1 }),
      Body.new(self, { x: -0.9700043599999999, y: 0.2430875300000001, x_accel: 0.4662036849999999, y_accel: 0.43236573, mass: 1 }),
      Body.new(self, { x: 0.0, y: 0.0, x_accel: -0.9324073699999998, y_accel: -0.8647314600000001, mass: 1 })
    ]
  end

  def start_game
    game_music.play(true)
    self.end_game_menu_active = false
    self.game_over_message = false
    self.elapsed_time_start = Gosu.milliseconds
    self.game_duration = 0
    self.score_modifier = 1
    self.score = 0
    self.game_active = true
  end

  def end_game
    reset_game
    self.end_game_menu_active = true
  end

  def game_over
    death_sound.play
    reset_game
    self.end_game_menu_active = true
    self.game_over_message = true
  end

  def exit_to_main_menu
    self.end_game_menu_active = false
  end

  def display_how_to_play
    self.how_to_play_active = true
  end

  def draw_game_over_menu
    option_font.draw_text_rel('GAME OVER. OOF.', 400, 310, 4, 0.5, 0, 1, 1, WHITE)
    option_font.draw_text_rel("SCORE: #{score}", 400, 350, 4, 0.5, 0, 1, 1, WHITE)
  end

  def draw_end_game_menu
    option_font.draw_text_rel('YOU SURVIVED. NICE.', 400, 310, 4, 0.5, 0, 1, 1, WHITE)
    option_font.draw_text_rel("SCORE: #{score}", 400, 350, 4, 0.5, 0, 1, 1, WHITE)
  end

  def display_credits
    self.credits_active = true
  end

  def quit
    close
  end

  def formatted_body_values
    bodies.inject([]) do |values, body|
      values += [body.x, body.y, body.x_accel, body.y_accel]
    end
  end

  def update_bodies_with_new_values(values)
    bodies.each_with_index do |body, i|
      starting_index = i*4
      body.update_state(values.slice(starting_index, 4))
    end
  end

  # Magic
  def rungeKutta(h)
    a = [h/2, h/2, h, 0]
    b = [h/6, h/3, h/3, h/6]
    u0 = []
    ut = []
    u = formatted_body_values

    u.length.times do |i|
      u0.push(u[i])
      ut.push(0)
    end

    4.times do |j|
      u = formatted_body_values
      du = derivative

      u.length.times do |i|
        u[i] = u0[i] + a[j]*du[i]
        update_bodies_with_new_values(u)
        ut[i] = ut[i] + b[j]*du[i]
      end

      update_bodies_with_new_values(u)
    end

    u.length.times do |i|
      u[i] = u0[i] + ut[i]
    end

    update_bodies_with_new_values(u)
  end

  def derivative
    du = Array.new(bodies.length)

    bodies.each_with_index do |body, i|
      body_start = i * 4

      du[body_start + 0] = body.x_accel
      du[body_start + 1] = body.y_accel
      du[body_start + 2] = body.accelerate(:x, bodies, butterfly)
      du[body_start + 3] = body.accelerate(:y, bodies, butterfly)
    end

    du
  end

  def update_position(timestep)
    rungeKutta(timestep)
  end

  def points
    @points ||= (0..800).to_a.map { |x| Point.new(x, rand(0..600)) }
  end
end

window = ButterflySurfer.new
window.show
