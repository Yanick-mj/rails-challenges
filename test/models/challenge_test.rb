require "test_helper"

class ChallengeTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  def setup
    @user = users(:one)
    @challenge = Challenge.new(
      name: "Test Challenge",
      description: "Test Description",
      start_date: Date.current + 1.week,
      end_date: Date.current + 2.weeks,
      max_participants: 10,
      user: @user
    )

    # Configurer l'adaptateur de test pour ActiveJob
    ActiveJob::Base.queue_adapter = :test
  end

  # ========================================
  # TESTS DE VALIDATION
  # ========================================

  test "should be valid with valid attributes" do
    assert @challenge.valid?
  end

  test "should require name" do
    @challenge.name = nil
    assert_not @challenge.valid?
    assert_includes @challenge.errors[:name], "can't be blank"
  end

  test "should require description" do
    @challenge.description = nil
    assert_not @challenge.valid?
    assert_includes @challenge.errors[:description], "can't be blank"
  end

  test "should require description with minimum length" do
    @challenge.description = "1234"
    assert_not @challenge.valid?
    assert_includes @challenge.errors[:description], "is too short (minimum is 5 characters)"
  end

  test "should require description with maximum length" do
    @challenge.description = "a" * 501
    assert_not @challenge.valid?
    assert_includes @challenge.errors[:description], "is too long (maximum is 500 characters)"
  end

  test "should require start_date" do
    @challenge.start_date = nil
    assert_not @challenge.valid?
    assert_includes @challenge.errors[:start_date], "can't be blank"
  end

  test "should require end_date" do
    @challenge.end_date = nil
    assert_not @challenge.valid?
    assert_includes @challenge.errors[:end_date], "can't be blank"
  end

  test "should require max_participants" do
    @challenge.max_participants = nil
    assert_not @challenge.valid?
    assert_includes @challenge.errors[:max_participants], "can't be blank"
  end

  test "should validate max_participants is greater than 0" do
    @challenge.max_participants = 0
    assert_not @challenge.valid?
    assert_includes @challenge.errors[:max_participants], "must be greater than 0"
  end

  test "should validate max_participants is less than or equal to 100" do
    @challenge.max_participants = 101
    assert_not @challenge.valid?
    assert_includes @challenge.errors[:max_participants], "must be less than or equal to 100"
  end

  test "should validate end_date is after start_date" do
    @challenge.end_date = @challenge.start_date - 1.day
    assert_not @challenge.valid?
    assert_includes @challenge.errors[:end_date], "must be after the start date"
  end

  test "should not allow start_date in the past on create" do
    @challenge.start_date = Date.current - 1.day
    assert_not @challenge.valid?
    assert_includes @challenge.errors[:start_date], "ne peut pas être dans le passé"
  end

  # ========================================
  # TESTS DES MÉTHODES
  # ========================================

  test "should calculate available spots correctly" do
    @challenge.save!
    assert_equal 10, @challenge.available_spots

    # Ajouter un participant
    @challenge.participants << users(:two)
    assert_equal 9, @challenge.available_spots
  end

  test "should detect when challenge is full" do
    @challenge.max_participants = 2
    @challenge.save!

    assert_not @challenge.full?

    @challenge.participants << users(:two)
    @challenge.participants << users(:three)

    assert @challenge.full?
  end

  test "should allow participation when user can participate" do
    @challenge.save!
    user = users(:two)

    assert @challenge.can_participate?(user)
  end

  test "should not allow participation when challenge is full" do
    @challenge.max_participants = 1
    @challenge.save!
    @challenge.participants << users(:two)

    user = users(:three)
    assert_not @challenge.can_participate?(user)
  end

  test "should not allow participation when user already participates" do
    @challenge.save!
    user = users(:two)
    @challenge.participants << user

    assert_not @challenge.can_participate?(user)
  end

  test "should not allow participation when user is nil" do
    @challenge.save!
    assert_not @challenge.can_participate?(nil)
  end

    # ========================================
    # TESTS DES SCOPES
    # ========================================

    test "should scope upcoming challenges" do
    @challenge.save!
    past_challenge = Challenge.new(
      name: "Past Challenge",
      description: "Past Description",
      start_date: Date.current - 2.weeks,
      end_date: Date.current - 1.week,
      max_participants: 10,
      user: @user
    )
    # Contourner la validation pour créer un challenge passé
    past_challenge.save!(validate: false)

    upcoming_challenges = Challenge.upcoming
    assert_includes upcoming_challenges, @challenge
    assert_not_includes upcoming_challenges, past_challenge
  end

  test "should scope active challenges" do
    @challenge.start_date = Date.current - 1.day
    @challenge.end_date = Date.current + 1.day
    @challenge.save!(validate: false) # Contourner la validation

    active_challenges = Challenge.active
    assert_includes active_challenges, @challenge
  end

  # ========================================
  # TESTS DES CALLBACKS
  # ========================================

  test "should send challenge created email after creation" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      @challenge.save!
    end
  end

  test "should not send challenge created email if no user" do
    @challenge.user = nil
    assert_no_enqueued_jobs do
      @challenge.save!
    end
  end

  # ========================================
  # TESTS DES ASSOCIATIONS
  # ========================================

  test "should belong to user" do
    assert_respond_to @challenge, :user
  end

  test "should have many challenge participations" do
    assert_respond_to @challenge, :challenge_participations
  end

  test "should have many participants through challenge participations" do
    assert_respond_to @challenge, :participants
  end
end
