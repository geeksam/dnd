module WallOfWater
  class Visualizer
    LEFT_PAD = " " * 5
    X_TICK_INTERVAL = 5
    Y_TICK_INTERVAL = 5
    GLYPHS = {
      attacker:          "A ",
      bottom_of_wall:    "+-",
      ground:            "--",
      nothing:           "  ",
      target:            "T ",
      target_sight_line: "* ",
      wall:              "| ",
      wall_sight_line:   "· ",
    }

    attr_reader :world
    def initialize(world)
      @world  = world
      @finder = ThingFinder.new(world)
    end

    def to_s
      <<~EOF


        #{plot}
        #{x_ticks}
        #{x_labels}

        #{poi_lines}

        #{upshot}

      EOF
    end

    private

    def x_range ; x1, x2 = world.points_of_interest.map(&:x).minmax ; (x1..x2) ; end
    def y_range ; y1, y2 = 0, world.points_of_interest.map(&:y).max ; (y1..y2) ; end

    def x_tick?(x) ; (x % X_TICK_INTERVAL).zero? ; end
    def y_tick?(y) ; (y % Y_TICK_INTERVAL).zero? ; end



    def plot
      y_range
        .map { |y| plot_line(y) }
        .reverse
        .join("\n")
    end

      def plot_line(y)
        LEFT_PAD + y_axis_prefix(y) + plot_line_points(y) + y_axis_suffix(y)
      end

        Y_AXIS_BLANK = " " * 4
        def y_axis_prefix(y) ; y_tick?(y) ? "%-2d  " % y : Y_AXIS_BLANK ; end
        def y_axis_suffix(y) ; y_tick?(y) ? "  %2d"  % y : Y_AXIS_BLANK ; end

        def plot_line_points(y)
          x_range.map { |x| GLYPHS.fetch( @finder.thing_at(x, y) ) }.join
        end



    def x_ticks
      glyphs = x_range.map { |x| x_tick?(x) ? "^ " : "  " }.join
      LEFT_PAD + Y_AXIS_BLANK + glyphs
    end

    def x_labels
      labels = x_range.map { |x| x_tick?(x) ? x.to_s : "  " }
      LEFT_PAD + Y_AXIS_BLANK + combine_labels(labels)
    end

      def combine_labels(labels)
        labels.join.gsub(/(\d+)(\s+)/) {
          spaces = 10 - $1.length
          "#{$1}#{' ' * spaces}"
        }
      end



    def poi_lines
      pois = world.points_of_interest
      label_width = pois.map { |e| e.label&.length }.compact.max + 1
      template = "#{LEFT_PAD + Y_AXIS_BLANK}%-#{label_width}s %s"
      num_width = pois.map(&:num_width).max
      pois.map { |pt| template % [ pt.label + ":", pt.align(num_width) ] }.join("\n")
    end



    def upshot
      "#{LEFT_PAD + Y_AXIS_BLANK}Walls between attacker and target: #{world.layers_to_target}"
    end

  end
end
