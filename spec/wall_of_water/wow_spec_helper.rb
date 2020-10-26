require_relative '../../lib/wall_of_water'

RSpec.shared_context "Wall of Water" do
  let(:inputs) {
    {
      attacker_y:    0,
      first_wall_x:  30,
      second_wall_x: 50,
      wall_height:   20,
      target_y:      15,
      target_x:      75,
    }
  }
  let(:world) { WallOfWater::World.new(**inputs) }
end
