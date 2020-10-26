require_relative 'wow_spec_helper'

RSpec.describe WallOfWater::World do
  include_context "Wall of Water"

  it "has various attributes, some provided and some computed" do
    expect( world.attacker_y  ).to eq(  0 )
    expect( world.wall_height ).to eq( 20 )
    expect( world.target_y    ).to eq( 15 )
    expect( world.target_x    ).to eq( 75 )

    expect( world.first_wall  ).to eq( Point(30, 20) )
    expect( world.second_wall ).to eq( Point(50, 20) )
  end

  it "complains if you tell it the attacker is below the ground" do
    inputs[:attacker_y] = -1
    expect { WallOfWater::World.new(**inputs) }.to \
      raise_error(ArgumentError, /attacker/)
  end

  it "complains if you tell it the target is below the ground" do
    inputs[:target] = -1
    expect { WallOfWater::World.new(**inputs) }.to \
      raise_error(ArgumentError, /target/)
  end

  describe "angle calculation" do
    it "calculates the angles to both walls and the target in degrees" do
      aggregate_failures do
        expect( world.first_wall.angle  ).to be_within( 0.1 ).of( 33.7 )
        expect( world.second_wall.angle ).to be_within( 0.1 ).of( 21.8 )
        expect( world.target.angle      ).to be_within( 0.1 ).of( 11.3 )
      end
    end
  end

  describe "graphing lines" do
    before do
      world.first_wall_x = world.wall_height
      expect( world.first_wall.angle ).to be_within( 0.1 ).of( 45 ) # precondition check
    end

    it "calculates integer coordinates along the first wall sight line" do
      points = world.first_wall_sight_line
      expect( points[0]  ).to eq( Point(  1,  1 ) )
      expect( points[1]  ).to eq( Point(  2,  2 ) )
      expect( points[-2] ).to eq( Point( 18, 18 ) )
      expect( points[-1] ).to eq( Point( 19, 19 ) )
    end

    it "calculates integer coordinates along the second wall angle" do
      points = world.second_wall_sight_line
      expect( points[0]  ).to eq( Point(  5,  2 ) )
      expect( points[1]  ).to eq( Point( 10,  4 ) )
      expect( points[-2] ).to eq( Point( 40, 16 ) )
      expect( points[-1] ).to eq( Point( 45, 18 ) )
    end

    it "calculates integer coordinates along the target angle" do
      points = world.target_sight_line
      expect( points[0]  ).to eq( Point(  5,  1 ) )
      expect( points[1]  ).to eq( Point( 10,  2 ) )
      expect( points[-2] ).to eq( Point( 65, 13 ) )
      expect( points[-1] ).to eq( Point( 70, 14 ) )
    end
  end

  describe "layer calculation" do
    # First things first; let's make the math easier
    before do
      world.wall_height   = 10
      world.first_wall_x  = 10
      world.second_wall_x = 30

      world.target_x = 40
      world.target_y = 5
    end

    context "attacker on the ground" do
      before do
        world.attacker_y = 0
      end

      context "attacker outside walls" do
        context "target in front of both walls" do
          before do
            world.target_x = 8
            world.target_y = 4
          end

          specify "zero layers" do
            expect( world.layers_to_target ).to eq( 0 )
          end
        end

        context "target between walls" do
          before do
            world.target_x = 12
          end

          specify "zero layers when target is up high" do
            world.target_y = 15
            expect( world.layers_to_target ).to eq( 0 )
          end

          specify "one layer when target is *just* behind the top of the wall" do
            world.target_x     = world.first_wall_x + 2
            world.target_y     = world.wall_height + 2
            expect( world.target_angle ).to eq( world.first_wall_angle ) # precondition

            expect( world.layers_to_target ).to eq( 1 )
          end

          specify "one layer when target is down low" do
            world.target_x     = world.first_wall_x + 2
            world.target_y     = world.wall_height - 2
            expect( world.layers_to_target ).to eq( 1 )
          end
        end

        context "target in first wall" do
          before do
            world.target_x = 10
            world.target_y = 2
          end

          specify "zero layers" do
            expect( world.layers_to_target ).to eq( 0 )
          end
        end

        context "target in second wall" do
          before do
            world.target_x = world.second_wall.x
            world.target_y = 6
          end

          specify "one layer when target in second wall" do
            expect( world.layers_to_target ).to eq( 1 )
          end
        end

        context "target beyond both walls" do
          before do
            world.wall_height   = 10
            world.first_wall_x  = 10
            world.second_wall_x = 20
            world.target_x      = 25
          end

          specify "zero layers when target is way up high" do
            world.target_y = 30
            expect( world.target_angle ).to be > world.first_wall_angle

            expect( world.layers_to_target ).to eq( 0 )
          end

          specify "one layer when target is *just* behind the top of the first wall" do
            world.target_y = 25
            expect( world.target_angle ).to be == world.first_wall_angle

            expect( world.layers_to_target ).to eq( 1 )
          end

          specify "one layer when target is below the top of the first wall but above the top of the second" do
            world.target_y = 15
            expect( world.target_angle ).to be < world.first_wall_angle
            expect( world.target_angle ).to be > world.second_wall_angle

            expect( world.layers_to_target ).to eq( 1 )
          end

          specify "two layers when target is *just* behind the top of the second wall" do
            world.target_x = 30
            world.target_y = 15
            expect( world.target_angle ).to be == world.second_wall_angle

            expect( world.layers_to_target ).to eq( 2 )
          end

          specify "two layers when target is down low" do
            world.target_y = 5
            expect( world.target_angle ).to be < world.second_wall_angle

            expect( world.layers_to_target ).to eq( 2 )
          end
        end
      end

      context "attacker in first wall" do
        before do
          world.first_wall_x = 0  # attacker is at x=0 by definition
        end

        xspecify "??? layers when target ALSO in first wall" do
          world.target_x = world.first_wall_x
          expect( world.layers_to_target ).to eq( 0 )
        end

        specify "zero layers when target is between walls" do
          world.target_x = world.first_wall.x + 5
          expect( world.layers_to_target ).to eq( 0 )
        end

        specify "zero layers when target in second wall" do
          world.target_x = world.second_wall_x
          expect( world.layers_to_target ).to eq( 0 )
        end

        specify "one layer when target is behind second wall" do
          world.target_x = world.second_wall_x + 5
          expect( world.layers_to_target ).to eq( 1 )
        end
      end

      context "attacker between walls" do
        before do
          world.first_wall_x = -10  # attacker is at x=0 by definition
        end

        specify "zero layers when target is between walls" do
          world.target_x = 5
          expect( world.layers_to_target ).to eq( 0 )
        end

        specify "zero layers when target in first wall" do
          world.target_x = world.first_wall_x
          expect( world.layers_to_target ).to eq( 0 )
        end

        specify "zero layers when target in second wall" do
          world.target_x = world.second_wall_x
          expect( world.layers_to_target ).to eq( 0 )
        end

        specify "one layer when target is behind first wall" do
          world.target_x = -15
          expect( world.layers_to_target ).to eq( 1 )
        end

        specify "one layer when target is behind second wall" do
          world.target_x = world.second_wall_x + 5
          expect( world.layers_to_target ).to eq( 1 )
        end
      end

    end

    context "attacker above ground" do
      before do
        world.attacker_y = 5
      end

      context "attacker outside walls" do
        context "target in front of both walls" do
          before do
            world.target_x = 8
            world.target_y = world.attacker_y
          end

          specify "zero layers" do
            expect( world.layers_to_target ).to eq( 0 )
          end
        end

        context "target between walls" do
          before do
            world.target_x = 12
          end

          specify "zero layers when target is up high" do
            world.target_y = 15
            expect( world.layers_to_target ).to eq( 0 )
          end

          specify "one layer when target is *just* behind the top of the wall" do
            world.target_x = 20
            world.target_y = 15
            expect( world.target_angle ).to eq( world.first_wall_angle ) # precondition

            expect( world.layers_to_target ).to eq( 1 )
          end

          specify "one layer when target is down low" do
            world.target_x     = world.first_wall_x + 2
            world.target_y     = world.wall_height - 2
            expect( world.layers_to_target ).to eq( 1 )
          end
        end

        context "target in first wall" do
          before do
            world.target_x = 10
            world.target_y = 5
          end

          specify "zero layers" do
            expect( world.layers_to_target ).to eq( 0 )
          end
        end

        context "target in second wall" do
          before do
            world.target_x = world.second_wall.x
            world.target_y = 5
          end

          specify "one layer when target in second wall" do
            expect( world.layers_to_target ).to eq( 1 )
          end
        end

        context "target beyond both walls" do
          before do
            world.wall_height   = 10
            world.first_wall_x  = 10
            world.second_wall_x = 20
            world.target_x      = 25
          end

          specify "zero layers when target is way up high" do
            world.target_y = 25
            expect( world.target_angle ).to be > world.first_wall_angle

            expect( world.layers_to_target ).to eq( 0 )
          end

          specify "one layer when target is *just* behind the top of the first wall" do
            world.target_x = 20
            world.target_y = 15
            expect( world.target_angle ).to be == world.first_wall_angle

            expect( world.layers_to_target ).to eq( 1 )
          end

          specify "one layer when target is below the top of the first wall but above the top of the second" do
            world.target_y = 15
            expect( world.target_angle ).to be < world.first_wall_angle
            expect( world.target_angle ).to be > world.second_wall_angle

            expect( world.layers_to_target ).to eq( 1 )
          end

          specify "two layers when target is *just* behind the top of the second wall" do
            world.target_x = 40
            world.target_y = 15
            expect( world.target_angle ).to be == world.second_wall_angle

            expect( world.layers_to_target ).to eq( 2 )
          end

          specify "one layer when target is down low" do
            world.target_y = 5
            expect( world.target_angle ).to be < world.second_wall_angle

            expect( world.layers_to_target ).to eq( 2 )
          end
        end
      end

      context "attacker in first wall" do
        before do
          world.first_wall_x = 0  # attacker is at x=0 by definition
        end

        xspecify "??? layers when target ALSO in first wall" do
          world.target_x = world.first_wall_x
          expect( world.layers_to_target ).to eq( 0 )
        end

        specify "zero layers when target is between walls" do
          world.target_x = world.first_wall.x + 5
          expect( world.layers_to_target ).to eq( 0 )
        end

        specify "zero layers when target in second wall" do
          world.target_x = world.second_wall_x
          expect( world.layers_to_target ).to eq( 0 )
        end

        specify "one layer when target is behind second wall" do
          world.target_x = world.second_wall_x + 5
          expect( world.layers_to_target ).to eq( 1 )
        end
      end

      context "attacker between walls" do
        before do
          world.first_wall_x = -10  # attacker is at x=0 by definition
        end

        specify "zero layers when target is between walls" do
          world.target_x = 5
          expect( world.layers_to_target ).to eq( 0 )
        end

        specify "zero layers when target in first wall" do
          world.target_x = world.first_wall_x
          expect( world.layers_to_target ).to eq( 0 )
        end

        specify "zero layers when target in second wall" do
          world.target_x = world.second_wall_x
          expect( world.layers_to_target ).to eq( 0 )
        end

        specify "one layer when target is behind first wall" do
          world.target_x = -15
          expect( world.layers_to_target ).to eq( 1 )
        end

        specify "one layer when target is behind second wall" do
          world.target_x = world.second_wall_x + 5
          expect( world.layers_to_target ).to eq( 1 )
        end
      end

    end
  end
end

