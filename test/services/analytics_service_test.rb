require "test_helper"

class AnalyticsServiceTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @challenge = challenges(:one)
  end

  # ========================================
  # TESTS DE BASE
  # ========================================

  test "should track event without raising error" do
    assert_nothing_raised do
      AnalyticsService.track_event(@user, "Test Event", { test: "data" })
    end
  end

  test "should track event without user (anonymous)" do
    assert_nothing_raised do
      AnalyticsService.track_event(nil, "Test Event", { test: "data" })
    end
  end

  # ========================================
  # TESTS DES ÉVÉNEMENTS DE CHALLENGE
  # ========================================

  test "should track challenge created without error" do
    assert_nothing_raised do
      AnalyticsService.track_challenge_created(@user, @challenge)
    end
  end

  test "should track challenge joined without error" do
    assert_nothing_raised do
      AnalyticsService.track_challenge_joined(@user, @challenge)
    end
  end

  test "should track challenge left without error" do
    # Créer une participation pour tester le calcul du temps
    participation = ChallengeParticipation.create!(
      user: @user,
      challenge: @challenge
    )

    assert_nothing_raised do
      AnalyticsService.track_challenge_left(@user, @challenge)
    end
  end

  # ========================================
  # TESTS DES ÉVÉNEMENTS D'UTILISATEUR
  # ========================================

  test "should track complete signup without error" do
    assert_nothing_raised do
      AnalyticsService.track_complete_signup(@user)
    end
  end

  test "should track signup failed without error" do
    assert_nothing_raised do
      AnalyticsService.track_signup_failed("test@example.com", {})
    end
  end

  test "should track complete login without error" do
    assert_nothing_raised do
      AnalyticsService.track_complete_login(@user)
    end
  end

  test "should track login failed without error" do
    assert_nothing_raised do
      AnalyticsService.track_login_failed("test@example.com")
    end
  end

  # ========================================
  # TESTS DES ÉVÉNEMENTS D'ERREUR
  # ========================================

  test "should track validation error without error" do
    errors = Struct.new(:count, :full_messages).new(2, [ "Error 1", "Error 2" ])

    assert_nothing_raised do
      AnalyticsService.track_validation_error(@user, "Challenge", errors)
    end
  end

  test "should track general error without error" do
    assert_nothing_raised do
      AnalyticsService.track_error(@user, "Test Error", "Something went wrong", { test: "data" })
    end
  end

  # ========================================
  # TESTS DES MÉTHODES PRIVÉES
  # ========================================

  test "should calculate time in challenge correctly" do
    # Créer une participation avec une date de création spécifique
    participation = ChallengeParticipation.create!(
      user: @user,
      challenge: @challenge,
      created_at: 2.days.ago
    )

    time_in_challenge = AnalyticsService.send(:calculate_time_in_challenge, @user, @challenge)
    assert_equal 2.0, time_in_challenge
  end

  test "should return 0 for time in challenge when no participation" do
    time_in_challenge = AnalyticsService.send(:calculate_time_in_challenge, @user, @challenge)
    assert_equal 0, time_in_challenge
  end

  # ========================================
  # TESTS DE ROBUSTESSE
  # ========================================

  test "should handle nil user gracefully" do
    assert_nothing_raised do
      AnalyticsService.track_event(nil, "Test Event", {})
    end
  end

  test "should handle nil properties gracefully" do
    assert_nothing_raised do
      AnalyticsService.track_event(@user, "Test Event", nil)
    end
  end

  test "should handle empty properties gracefully" do
    assert_nothing_raised do
      AnalyticsService.track_event(@user, "Test Event", {})
    end
  end

  # ========================================
  # TESTS DE CONFIGURATION
  # ========================================

  test "should have mixpanel configured" do
    assert_not_nil $mixpanel
  end

  test "should have mixpanel token configured" do
    assert_not_nil MIXPANEL_TOKEN
    assert_equal "ce5d905d78e7112a08dc81e5624a4c42", MIXPANEL_TOKEN
  end
end
