#! /usr/bin/ruby

require 'rubygems'
require 'rubygame'

include Rubygame

class Ball
  
  attr_accessor :leader, :center
  attr_reader :radius, :moving


  def initialize(screen, color = [0, 0, 0xff], radius = 6)
    @screen = screen
    @center = [rand(screen.size[0]) ,rand(screen.size[1]) ]
    @radius = radius
    @color = color
    @speed = [0,0]
    @moving = false
    randomize
  end

  def randomize()
    @speed = rand(5) + 4
    @distance = rand(60) + 10
  end

  def draw(screen)
    @screen.draw_circle @center, @radius, @color
  end

  def update()
    if @leader
      delta_x, delta_y, distance = distance_with_parts(@leader)
      speed = [distance - (@leader.radius + @radius), @speed].min
      if (speed < 0.2)
        @moving = false
        
      end
      if (@moving || distance > @distance)
        center[0] += speed * delta_x / distance
        center[1] += speed * delta_y / distance
        @moving = true
      end
      randomize
    end
  end
  
  def distance(ball)
    delta_x = (ball.center[0] - @center[0])
    delta_y = (ball.center[1] - @center[1])
    Math.sqrt((delta_x * delta_x) + (delta_y * delta_y))
  end

  def distance_with_parts(ball)
    delta_x = (ball.center[0] - @center[0])
    delta_y = (ball.center[1] - @center[1])
    return delta_x, delta_y, Math.sqrt((delta_x * delta_x) + (delta_y * delta_y))
  end
end


@screen = Screen.open Screen.get_resolution
@screen.title = "Flock"
@screen.show_cursor = false

@event_queue = EventQueue.new
@event_queue.enable_new_style_events

@clock = Clock.new
@clock.target_framerate = 60
@clock.enable_tick_events

should_run = true
background = [0,0,0]
color = [0xff, 0x0, 0x0]
radius = 10


mouse_ball = Ball.new(@screen, color, radius)

ball_list = []

cur_ball = mouse_ball

50.times do
  ball_list << Ball.new(@screen)
  ball_list[-1].leader = cur_ball
  #cur_ball = ball_list[-1]
end

while should_run
  seconds_passed = @clock.tick().seconds
  @screen.fill background

  

  ball_list.each do |ball|
    ball.draw @screen
    ball.update
  end
  mouse_ball.draw @screen  


  @screen.flip()


  (0...ball_list.size).each do |i|
    ((i+1)...ball_list.size).each do |j|
      ball = ball_list[i] 
      collide = ball_list[j]
      delta_x, delta_y, distance = ball.distance_with_parts(collide)
      if ( distance < ball.radius + collide.radius)
        ball.center[0] += (ball.radius+collide.radius) - distance       
        #collide.center[0] -= (ball.center[0] += (((ball.radius + collide.radius) * delta_x) / distance)/2 )
       #collide.center[1] -= (ball.center[1] += (((ball.radius + collide.radius) * delta_y) / distance)/2 )
      end
    end
  end  
  @event_queue.each do |event|
     case event
       when Events::QuitRequested
         should_run = false
       when Events::MouseMoved
         mouse_ball.center = event.pos
     end
  end

  
end


