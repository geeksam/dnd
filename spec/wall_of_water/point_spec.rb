require_relative 'wow_spec_helper'

RSpec.describe WallOfWater::Point do

  describe "point arithmetic" do
    # NOTE: Q ==> Quadrant
    specify "two points can be added to produce a third" do
      expect( Point(1, 2) + Point(4, 7) ).to eq( Point(5, 9) )
    end

    specify "two points can be subtracted to produce a third" do
      expect( Point(5, 5) - Point(1, 2) ).to eq( Point(4, 3) )
    end
  end

  specify "#reduce" do
    expect( Point(4, 4).reduce ).to eq( Point(1, 1) )
  end

  specify "#angle" do
    first_wall  = Point(30, 20)
    second_wall = Point(50, 20)
    target      = Point(75, 15)

    expect( first_wall.angle  ).to be_within( 0.1 ).of( 33.7 )
    expect( second_wall.angle ).to be_within( 0.1 ).of( 21.8 )
    expect( target.angle      ).to be_within( 0.1 ).of( 11.3 )
  end

  specify "#angle(to: a_point)" do
    origin = Point(0, 0)
    first_wall  = Point(30, 20)
    second_wall = Point(50, 20)
    target      = Point(75, 15)

    expect( origin.angle(to: first_wall)  ).to be_within( 0.1 ).of( 33.7 )
    expect( origin.angle(to: second_wall) ).to be_within( 0.1 ).of( 21.8 )
    expect( origin.angle(to: target)      ).to be_within( 0.1 ).of( 11.3 )
  end

  specify "#reduced_vector" do
    aggregate_failures do
      # fractions are reduced (even if y=0)
      expect( Point( 4, 4).reduced_vector ).to eq( Point( 1, 1) )
      expect( Point( 4, 0).reduced_vector ).to eq( Point( 1, 0) )

      # Unit vectors
      expect( Point( 0,  1).reduced_vector ).to eq( Point( 0,  1) ) # north
      expect( Point( 1,  0).reduced_vector ).to eq( Point( 1,  0) ) # east
      expect( Point( 0, -1).reduced_vector ).to eq( Point( 0, -1) ) # south
      expect( Point(-1,  0).reduced_vector ).to eq( Point(-1,  0) ) # west

      expect( Point( 4,  4).reduced_vector(from: Point( 1,  1)) ).to eq( Point( 1,  1) ) # fractions are reduced
      expect( Point( 4,  4).reduced_vector(from: Point( 5,  2)) ).to eq( Point(-1,  2) )
      expect( Point( 4,  4).reduced_vector(from: Point(-1,  1)) ).to eq( Point( 5,  3) )
      expect( Point( 4, -4).reduced_vector                      ).to eq( Point( 1, -1) )
      expect( Point( 4, -4).reduced_vector(from: Point( 0, -2)) ).to eq( Point( 2, -1) )
    end
  end

  describe "a point along y = x" do
    let(:p0) { Point(0, 0) }
    let(:p1) { Point(1, 1) }
    let(:p2) { Point(2, 2) }
    let(:p3) { Point(3, 3) }
    let(:p4) { Point(4, 4) }

    specify "its sight line has three points" do
      expect( p4.sight_line ).to eq( [ p1, p2, p3 ] )
    end

    specify "the origin's sight line to it has three points" do
      expect( p0.sight_line(to: p4) ).to eq( [ p1, p2, p3 ] )
    end

    specify "its sight line from (0,2) has one point)" do
      pt = Point(0, 2)
      expect( p4.sight_line(from: pt ) ).to eq( [ Point(2, 3) ] )
    end

    specify "the origin's sight line to it has one point)" do
      pt = Point(0, 2)
      expect( pt.sight_line(to: p4 ) ).to eq( [ Point(2, 3) ] )
    end
  end

  describe "a point along y =-x" do
    let(:p0) { Point(0,  0) }
    let(:p1) { Point(1, -1) }
    let(:p2) { Point(2, -2) }
    let(:p3) { Point(3, -3) }
    let(:p4) { Point(4, -4) }

    specify "its sight line has three points" do
      expect( p4.sight_line ).to eq( [ p1, p2, p3 ] )
    end

    specify "its sight line from (0,-2) has one point" do
      expect( p4.sight_line(from: Point(0, -2) ) ).to eq( [ Point(2, -3) ] )
    end
  end

  describe "a point along y = (1/2)x" do
    let(:p0) { Point(0, 0) }
    let(:p1) { Point(2, 1) }
    let(:p2) { Point(4, 2) }

    specify "sight_line" do
      expect( p2.sight_line ).to eq( [ p1 ] )
    end
  end

  describe "a point along x = 5" do
    let(:p0) { Point(5, 0) }
    let(:p1) { Point(5, 1) }
    let(:p2) { Point(5, 2) }
    let(:p3) { Point(5, 3) }

    specify "sight_line" do
$debug = true
      expect( p0.sight_line(to: p3) ).to eq( [ p1, p2 ] )
    end
  end

  describe "a point along y = 5" do
    let(:p0) { Point(0, 5) }
    let(:p1) { Point(1, 5) }
    let(:p2) { Point(2, 5) }
    let(:p3) { Point(3, 5) }

    specify "sight_line" do
$debug = true
      expect( p0.sight_line(to: p3) ).to eq( [ p1, p2 ] )
    end
  end

end
