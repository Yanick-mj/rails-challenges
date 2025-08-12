require "test_helper"

class ChallengeParticipationTest < ActiveSupport::TestCase
  def setup
    @creator = User.create!(
      email: "creator@example.com",
      password: "password",
      first_name: "Creator",
      last_name: "User"
    )
    @participant = User.create!(
      email: "participant@example.com",
      password: "password",
      first_name: "Participant", 
      last_name: "User"
    )
    @challenge = Challenge.create!(
      name: "Test Challenge",
      description: "A test challenge",
      start_date: Date.current,
      end_date: Date.current + 1.week,
      user: @creator
    )
  end

  test "should be valid" do
    participation = ChallengeParticipation.new(challenge: @challenge, user: @participant)
    assert participation.valid?
  end

  test "should require challenge" do
    participation = ChallengeParticipation.new(user: @participant)
    assert_not participation.valid?
  end

  test "should require user" do
    participation = ChallengeParticipation.new(challenge: @challenge)
    assert_not participation.valid?
  end

  test "should prevent duplicate participations" do
    ChallengeParticipation.create!(challenge: @challenge, user: @participant)
    
    duplicate = ChallengeParticipation.new(challenge: @challenge, user: @participant)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "already participating in this challenge"
  end

  test "should prevent challenge creator from participating" do
    participation = ChallengeParticipation.new(challenge: @challenge, user: @creator)
    assert_not participation.valid?
    assert_includes participation.errors[:user], "cannot participate in their own challenge"
  end

  test "should prevent participation when challenge is full" do
    # Fill the challenge with 10 participants
    10.times do |i|
      user = User.create!(
        email: "user#{i}@example.com",
        password: "password",
        first_name: "User",
        last_name: "#{i}"
      )
      ChallengeParticipation.create!(challenge: @challenge, user: user)
    end

    # Try to add 11th participant
    new_user = User.create!(
      email: "extra@example.com",
      password: "password",
      first_name: "Extra",
      last_name: "User"
    )
    
    participation = ChallengeParticipation.new(challenge: @challenge, user: new_user)
    assert_not participation.valid?
    assert_includes participation.errors[:challenge], "has reached maximum participants (10)"
  end

  test "should allow participation when challenge has available spots" do
    # Add 5 participants
    5.times do |i|
      user = User.create!(
        email: "user#{i}@example.com",
        password: "password",
        first_name: "User",
        last_name: "#{i}"
      )
      ChallengeParticipation.create!(challenge: @challenge, user: user)
    end

    # Should still allow more participants
    participation = ChallengeParticipation.new(challenge: @challenge, user: @participant)
    assert participation.valid?
  end

  test "should belong to challenge and user" do
    participation = ChallengeParticipation.create!(challenge: @challenge, user: @participant)
    
    assert_equal @challenge, participation.challenge
    assert_equal @participant, participation.user
  end

  test "should have timestamps" do
    participation = ChallengeParticipation.create!(challenge: @challenge, user: @participant)
    
    assert_not_nil participation.created_at
    assert_not_nil participation.updated_at
  end
end