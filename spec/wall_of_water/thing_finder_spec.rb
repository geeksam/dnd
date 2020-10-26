require_relative 'wow_spec_helper'

RSpec.describe WallOfWater::ThingFinder do
  include_context "Wall of Water"

  let(:finder) { WallOfWater::ThingFinder.new(world) }

  it "knows that nothing is at a random point" do
    expect( finder.thing_at( 1, 10 ) ).to eq( :nothing )
  end

  it "knows where the attacker is" do
    expect( finder.thing_at( 0, 0 ) ).to eq( :attacker )
  end

  it "knows where the target is" do
    expect( finder.thing_at( 75, 15 ) ).to eq( :target )
  end

  it "knows where the ground is" do
    (0..75).each do |x|
      next if x == 0  # attacker
      next if x == 30 # bottom of wall
      next if x == 50 # bottom of wall
      expect( finder.thing_at( x, 0 ) ).to eq( :ground )
    end
  end

  it "knows where the the first wall is" do
    expect( finder.thing_at( 30,  0 ) ).to eq( :bottom_of_wall )
    expect( finder.thing_at( 30,  1 ) ).to eq( :wall )
    expect( finder.thing_at( 30, 20 ) ).to eq( :wall )
    expect( finder.thing_at( 30, 21 ) ).to eq( :nothing )
  end


  it "knows where the rest of the second wall is" do
    expect( finder.thing_at( 50,  0 ) ).to eq( :bottom_of_wall )
    expect( finder.thing_at( 50,  1 ) ).to eq( :wall )
    expect( finder.thing_at( 50, 20 ) ).to eq( :wall )
    expect( finder.thing_at( 50, 21 ) ).to eq( :nothing )
  end

  it "knows that points on the first wall sight line are special" do
    points = world.first_wall_sight_line
    expected = :wall_sight_line
    points.each do |p|
      actual = finder.thing_at( p.x, p.y )
      expect( actual ).to eq( expected ), "#{p} expected #{expected.inspect}, got #{actual.inspect}"
    end
  end

  it "knows that points on the second wall sight line are special" do
    points = world.second_wall_sight_line
    expected = :wall_sight_line
    points[0..-1].each do |p|
      actual = finder.thing_at( p.x, p.y )
      expect( actual ).to eq( expected ), "#{p} expected #{expected.inspect}, got #{actual.inspect}"
    end
  end

  it "knows where to find points on the target sight line" do
    points = world.target_sight_line
    expected = :target_sight_line
    points[0..-1].each do |p|
      actual = finder.thing_at( p.x, p.y )
      expect( actual ).to eq( expected ), "#{p} expected #{expected.inspect}, got #{actual.inspect}"
    end
  end


  specify "when the target is *in* the wall, the visualizer reports the target instead of the wall" do
    world.target_x = world.first_wall_x
    expect( finder.thing_at(world.target_x, world.target_y) ).to eq( :target )
  end

  specify "when the target is *in* the wall's top space, the visualizer reports the target sight line instead of the wall sight line" do
    world.target_x = world.first_wall_x = 5
    world.target_y = world.wall_height  = 5
    (1..4).each do |i|
      expect( finder.thing_at(i, i) ).to eq( :target_sight_line )
    end
  end
end
