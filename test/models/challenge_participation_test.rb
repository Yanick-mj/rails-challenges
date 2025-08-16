require "test_helper"

class ChallengeParticipationTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @user = users(:one)
    @challenge = challenges(:one)
    @participation = ChallengeParticipation.new(
      user: @user,
      challenge: @challenge
    )

    # Configurer l'adaptateur de test pour ActiveJob
    ActiveJob::Base.queue_adapter = :test
  end

  # ========================================
  # TESTS DE VALIDATION
  # ========================================

  test "should be valid with valid attributes" do
    assert @participation.valid?
  end

  test "should require user" do
    @participation.user = nil
    assert_not @participation.valid?
    assert_includes @participation.errors[:user], "must exist"
  end

  test "should require challenge" do
    @participation.challenge = nil
    assert_not @participation.valid?
    assert_includes @participation.errors[:challenge], "must exist"
  end

  test "should require unique user per challenge" do
    @participation.save!
    duplicate_participation = ChallengeParticipation.new(
      user: @user,
      challenge: @challenge
    )
    assert_not duplicate_participation.valid?
    assert_includes duplicate_participation.errors[:challenge_id], "Vous participez déjà à ce challenge"
  end

  test "should not allow participation when challenge is full" do
    @challenge.max_participants = 1
    @challenge.save!

    # Ajouter un premier participant
    first_participation = ChallengeParticipation.create!(
      user: users(:two),
      challenge: @challenge
    )

    # Essayer d'ajouter un deuxième participant
    second_participation = ChallengeParticipation.new(
      user: users(:three),
      challenge: @challenge
    )

    assert_not second_participation.valid?
    assert_includes second_participation.errors[:base], "Ce challenge est complet (1 participants maximum)"
  end

  # ========================================
  # TESTS DES CALLBACKS
  # ========================================

  test "should send joined email after creation" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      @participation.save!
    end
  end

  test "should send left email after destruction" do
    @participation.save!

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      @participation.destroy
    end
  end

  # ========================================
  # TESTS DES ASSOCIATIONS
  # ========================================

  test "should belong to user" do
    assert_respond_to @participation, :user
  end

  test "should belong to challenge" do
    assert_respond_to @participation, :challenge
  end

  # ========================================
  # TESTS D'INTÉGRATION
  # ========================================

  test "should allow multiple users to participate in same challenge" do
    @participation.save!

    second_participation = ChallengeParticipation.new(
      user: users(:two),
      challenge: @challenge
    )

    assert second_participation.valid?
    assert second_participation.save
  end

  test "should allow same user to participate in different challenges" do
    @participation.save!

    second_challenge = Challenge.create!(
      name: "Second Challenge",
      description: "Second Description",
      start_date: Date.current + 1.week,
      end_date: Date.current + 2.weeks,
      max_participants: 10,
      user: users(:two)
    )

    second_participation = ChallengeParticipation.new(
      user: @user,
      challenge: second_challenge
    )

    assert second_participation.valid?
    assert second_participation.save
  end

  test "should update challenge participants count" do
    assert_equal 0, @challenge.participants.count

    @participation.save!
    @challenge.reload

    assert_equal 1, @challenge.participants.count
  end

  test "should remove user from challenge participants when destroyed" do
    @participation.save!
    @challenge.reload
    assert_equal 1, @challenge.participants.count

    @participation.destroy
    @challenge.reload
    assert_equal 0, @challenge.participants.count
  end

  # ========================================
  # TESTS DE VALIDATION COMPLEXE
  # ========================================

  test "should validate challenge not full with multiple participants" do
    @challenge.max_participants = 2
    @challenge.save!

    # Premier participant
    first_participation = ChallengeParticipation.create!(
      user: users(:two),
      challenge: @challenge
    )

    # Deuxième participant
    second_participation = ChallengeParticipation.create!(
      user: users(:three),
      challenge: @challenge
    )

    # Troisième participant (devrait échouer)
    third_participation = ChallengeParticipation.new(
      user: @user,
      challenge: @challenge
    )

    assert_not third_participation.valid?
    assert_includes third_participation.errors[:base], "Ce challenge est complet (2 participants maximum)"
  end

  test "should allow participation when challenge has available spots" do
    @challenge.max_participants = 3
    @challenge.save!

    # Ajouter deux participants
    ChallengeParticipation.create!(user: users(:two), challenge: @challenge)
    ChallengeParticipation.create!(user: users(:three), challenge: @challenge)

    # Le troisième devrait pouvoir participer
    third_participation = ChallengeParticipation.new(
      user: @user,
      challenge: @challenge
    )

    assert third_participation.valid?
    assert third_participation.save
  end
end
