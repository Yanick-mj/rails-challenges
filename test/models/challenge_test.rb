require "test_helper"

class ChallengeTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test@example.com", 
      password: "password",
      first_name: "Test",
      last_name: "User"
    )
    @challenge = Challenge.create!(
      name: "Test Challenge",
      description: "A test challenge",
      start_date: Date.current,
      end_date: Date.current + 1.week,
      user: @user
    )
    @participant = User.create!(
      email: "participant@example.com",
      password: "password", 
      first_name: "Participant",
      last_name: "User"
    )
  end

  test "should be valid" do
    assert @challenge.valid?
  end

  test "should require name" do
    @challenge.name = nil
    assert_not @challenge.valid?
  end

  test "should require description" do
    @challenge.description = nil
    assert_not @challenge.valid?
  end

  test "should require start date" do
    @challenge.start_date = nil
    assert_not @challenge.valid?
  end

  test "should require end date" do
    @challenge.end_date = nil
    assert_not @challenge.valid?
  end

  test "end date should be after start date" do
    @challenge.end_date = @challenge.start_date - 1.day
    assert_not @challenge.valid?
    assert_includes @challenge.errors[:end_date], "must be after the start date"
  end

  test "should belong to user" do
    assert_equal @user, @challenge.user
  end

  test "should have participants" do
    @challenge.challenge_participations.create!(user: @participant)
    assert_includes @challenge.participants, @participant
  end

  test "available_spots should return correct count" do
    assert_equal 10, @challenge.available_spots
    
    # Add 3 participants
    3.times do |i|
      user = User.create!(
        email: "user#{i}@example.com",
        password: "password",
        first_name: "User",
        last_name: "#{i}"
      )
      @challenge.challenge_participations.create!(user: user)
    end
    
    assert_equal 7, @challenge.available_spots
  end

  test "should not be full with less than 10 participants" do
    assert_not @challenge.full?
    
    # Add 5 participants
    5.times do |i|
      user = User.create!(
        email: "user#{i}@example.com",
        password: "password",
        first_name: "User",
        last_name: "#{i}"
      )
      @challenge.challenge_participations.create!(user: user)
    end
    
    assert_not @challenge.full?
  end

  test "should be full with 10 participants" do
    # Add 10 participants
    10.times do |i|
      user = User.create!(
        email: "user#{i}@example.com",
        password: "password",
        first_name: "User",
        last_name: "#{i}"
      )
      @challenge.challenge_participations.create!(user: user)
    end
    
    assert @challenge.full?
    assert_equal 0, @challenge.available_spots
  end

  test "can_participate should return false for challenge creator" do
    assert_not @challenge.can_participate?(@user)
  end

  test "can_participate should return false when challenge is full" do
    # Fill the challenge
    10.times do |i|
      user = User.create!(
        email: "user#{i}@example.com",
        password: "password",
        first_name: "User",
        last_name: "#{i}"
      )
      @challenge.challenge_participations.create!(user: user)
    end
    
    assert_not @challenge.can_participate?(@participant)
  end

  test "can_participate should return false if already participating" do
    @challenge.challenge_participations.create!(user: @participant)
    assert_not @challenge.can_participate?(@participant)
  end

  test "can_participate should return true for eligible user" do
    assert @challenge.can_participate?(@participant)
  end

  test "participation_status_for should return correct status" do
    assert_equal :not_logged_in, @challenge.participation_status_for(nil)
    assert_equal :own_challenge, @challenge.participation_status_for(@user)
    assert_equal :can_participate, @challenge.participation_status_for(@participant)
    
    @challenge.challenge_participations.create!(user: @participant)
    assert_equal :already_participating, @challenge.participation_status_for(@participant)
  end
end
