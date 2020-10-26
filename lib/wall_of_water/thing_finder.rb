module WallOfWater
  class ThingFinder
    attr_reader :world
    def initialize(world)
      @world = world
    end

    # this list short-circuits
    THINGS = %i[ attacker target target_sight_line wall_sight_line wall ground ]
    def thing_at(x, y)
      p = Point(x, y)
      thing_methods = THINGS.map { |e| method("thing_#{e}") }
      thing_methods.map { |m| m.call(p) }.compact.first || :nothing
    end

    def thing_attacker(p)
      p == world.attacker ? :attacker : nil
    end

    def thing_ground(p)
      p.y.zero? ? :ground : nil
    end

    def thing_target(p)
      p == world.target ? :target : nil
    end

    def thing_target_sight_line(p)
      world.target_sight_line.include?(p) ? :target_sight_line : nil
    end

    def thing_wall(p)
      return nil unless world.walls.map(&:x).include?(p.x)

      case p.y
      when 0                      ; return :bottom_of_wall
      when 1..(world.wall_height) ; return :wall
      else                        ; return :nothing
      end
    end

    def thing_wall_sight_line(p)
      return :wall_sight_line if world.first_wall_sight_line  .include?(p)
      return :wall_sight_line if world.second_wall_sight_line .include?(p)
      nil
    end


  end
end
