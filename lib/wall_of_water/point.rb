module WallOfWater
  class Point
    class NotAPoint < ArgumentError ; end

    attr_reader :x, :y, :label
    def initialize(x, y, label: nil)
      raise ArgumentError unless x.is_a?(Integer)
      raise ArgumentError unless y.is_a?(Integer)
      @x, @y = x, y
      @label = label
    end

    def ==(other)
      assert_point other
      self.components == other.components
    rescue NotAPoint
      return false
    end

    def +(other)
      transform_components other, :+
    end

    def -(other)
      transform_components other, :-
    end

    def reduce
      if y.zero? # avoid ZeroDivisionError
        px, py = 1, 0
      else
        r = Rational(*components.map(&:abs)) # we'll reapply the signs manually
        px, py = r.numerator, r.denominator
      end
      px *= sign(x)
      py *= sign(y)
      self.class.new(px, py)
    end

    def left_of?(other)
      assert_point other
      self.x < other.x
    end

    def right_of?(other)
      assert_point other
      other.x < self.x
    end

    def x_between?(other1, other2)
      assert_point other1, other2
      p1, p2 = [ other1, other2 ].sort_by(&:x)
      p1.left_of?(self) && self.left_of?(p2)
    end

    def to_s
      "(#{x}, #{y})"
    end

    def align(num_width)
      template = "( %#{num_width}d, %#{num_width}d )"
      template % components
    end

    def num_width
      components.map { |e| e.to_s.length }.max
    end

    def inspect
      to_s
    end

    # FIXME: do I actually need this method tho?
    def reduced_vector(from: nil, to: nil)
      a, b = sort_out(from, to)
      (b - a).reduce
    end

    def angle(from: nil, to: nil)
      a, b = sort_out(from, to)

      v = b.reduced_vector(from: a)
      rads = Math.atan( v.y.to_f / v.x )
      rads.to_f * 180 / Math::PI # convert to degrees
    end

    def sight_line(from: nil, to: nil)
      a, b = sort_out(from, to)
      # v = (b - a).reduce
      v = b.reduced_vector(from: a)

      points = []
      pt = a.dup
      loop do
        pt += v
        break if pt == b
        points << pt
      end
      points
    end

    protected

    def components
      [ x, y ]
    end

    def transform_components(other, message)
      assert_point other
      pairs = components.zip(other.components)
      self.class.new( *pairs.map { |a,b| a.send(message, b) } )
    end

    def sign(n)
      n < 0 ? -1 : 1
    end

    private

    def assert_point(*others)
      raise NotAPoint unless others.all? { |e| e.is_a?(self.class) }
    end

    def sort_out(from, to)
      case
      when from && to ; raise ArgumentError, "max of one reference point, please"
      when from       ; a, b = from, self
      when to         ; a, b = self, to
      else            ; a, b = ORIGIN, self
      end
      assert_point a, b
      return a, b
    end
  end

  class Point
    ORIGIN = Point.new(0, 0)
  end
end

def Point(x, y)
  WallOfWater::Point.new(x, y)
end
