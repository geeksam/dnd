#!/usr/bin/env ruby

require_relative 'lib/wall_of_water'

def get_number(msg)
  print msg
  val = $stdin.gets.to_s.strip
  return nil if val == ""
  val.to_i
end

def construct_world
  system "clear"

  puts <<~EOF

    This looks best with units in FEET (at least up to the width of your terminal).
    Multiply squares by 5!

  EOF

  wh = get_number("Wall height: ")
  w1 = get_number("Distance to first wall: ")
  w2 = get_number("Distance to second wall (blank if none): ")
  tx = get_number("Distance to target: ")
  ay = get_number("Attacker elevation: ")
  ty = get_number("Target elevation: ")

  return WallOfWater::World.new(
    wall_height:   wh,
    first_wall_x:  w1,
    second_wall_x: w2,
    target_x:      tx,
    attacker_y:    ay,
    target_y:      ty,
  )
end

begin
  loop do
    begin
      world = construct_world
      puts world
    rescue ArgumentError => e
      puts e.message
    end

    puts "(waiting)"
    $stdin.gets

    # There is no escaping the loop; you must hit ^C
  end
rescue Interrupt
  puts "\nHave fun storming the castle!\n"
  exit
end
