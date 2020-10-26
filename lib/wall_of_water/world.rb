module WallOfWater
  class World
    attr_accessor(*%i[ attacker_y target_x target_y first_wall_x second_wall_x wall_height ])
    def initialize(attacker_y:, first_wall_x:, second_wall_x:, wall_height:, target_x:, target_y:)
      @attacker_y    = attacker_y # NOTE: attacker X is hardcoded to zero

      @first_wall_x  = first_wall_x
      @second_wall_x = second_wall_x
      @wall_height   = wall_height

      @target_x      = target_x
      @target_y      = target_y

      messages = []
      messages << "- attacker is below the ground"            if attacker.y < 0
      messages << "- target is below the ground"              if target.y < 0
      messages << "- there's no separation between the walls" if first_wall_x == second_wall_x

      if messages.any?
        messages.unshift "Yeah, that won't work because:"
        raise ArgumentError, messages.join("\n")
      end
    end

    def attacker    ;                  Point.new( 0,             attacker_y,  label: "Attacker" ) ; end
    def target      ;                  Point.new( target_x,      target_y,    label: "Target"   ) ; end
    def first_wall  ;                  Point.new( first_wall_x,  wall_height, label: "Wall 1"   ) ; end
    def second_wall ; second_wall_x && Point.new( second_wall_x, wall_height, label: "Wall 2"   ) ; end

    def target_angle      ;                attacker.angle(to: target)      ; end
    def first_wall_angle  ;                attacker.angle(to: first_wall)  ; end
    def second_wall_angle ; second_wall && attacker.angle(to: second_wall) ; end

    def target_sight_line      ;                attacker.sight_line(to: target)            ; end
    def first_wall_sight_line  ;                attacker.sight_line(to: first_wall)        ; end
    def second_wall_sight_line ; second_wall && attacker.sight_line(to: second_wall) || [] ; end

    def walls
      [ first_wall, second_wall ].compact
    end

    def points_of_interest
      [ attacker, target, first_wall, second_wall ].compact.sort_by(&:x)
    end

    def layers_to_target
      walls.select { |wall| target_obscured_by?(wall) }.length
    end

    def to_s
      WallOfWater::Visualizer.new(self).to_s
    end

    private

    def target_obscured_by?(wall)
      return false unless wall.x_between?(target, attacker)

      a1 = attacker.angle(to: target)
      a2 = attacker.angle(to: wall)

      # TODO: I should probably understand why this worked even though my
      # assumption about the range of .angle (I thought it was 0..360) was
      # wrong
      if attacker.left_of?(wall)
        a1 <= a2
      else
        a1 >= a2
      end
    end
  end
end
