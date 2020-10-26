require_relative 'wow_spec_helper'

RSpec.describe WallOfWater::Visualizer do
  include_context "Wall of Water"

  let(:viz) { WallOfWater::Visualizer.new(world) }

  specify "everything copes with a missing second wall" do
    world = WallOfWater::World.new(
      wall_height:   20,

      attacker_y:    0,
      first_wall_x:  20,
      second_wall_x: nil, # hooboy
      target_y:      10,
      target_x:      25,
    )

    world.to_s # if this doesn't blow up, we're golden
  end
end
