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

expected = "\n\n     20                                          |             20\n                                               · |               \n                                             ·   |               \n                                           ·     |               \n                                         ·       |               \n     15                                ·         |             15\n                                     ·           |               \n                                   ·             |               \n                                 ·               |               \n                               ·                 |               \n     10                      ·                   |         T   10\n                           ·                     |               \n                         ·                       *               \n                       ·                         |               \n                     ·                 *         |               \n     5             ·                             |              5\n                 ·           *                   |               \n               ·                                 |               \n             ·     *                             |               \n           ·                                     |               \n     0   A --------------------------------------+-----------   0\n         ^         ^         ^         ^         ^         ^ \n         0         5         10        15        20        25\n\n         Attacker: (  0,  0 )\n         Wall 1:   ( 20, 20 )\n         Target:   ( 25, 10 )\n\n         Walls between attacker and target: 1\n\n"
actual = \
    world.to_s # if this doesn't blow up, we're golden
# puts actual
expect( actual ).to eq( expected )
  end
end
