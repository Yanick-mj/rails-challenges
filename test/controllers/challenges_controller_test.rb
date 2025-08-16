require "test_helper"

class ChallengesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @challenge = challenges(:one)

    # Configurer l'adaptateur de test pour ActiveJob
    ActiveJob::Base.queue_adapter = :test
  end

  test "should get index" do
    get challenges_url
    assert_response :success
    assert_select "h2", "Challenges"
  end

  test "should get new when authenticated" do
    sign_in @user
    get new_challenge_url
    assert_response :success
  end

  test "should redirect new when not authenticated" do
    get new_challenge_url
    assert_redirected_to new_user_session_path
  end

  test "should create challenge when authenticated" do
    sign_in @user
    assert_difference("Challenge.count") do
      post challenges_url, params: {
        challenge: {
          name: "Test Challenge",
          description: "Test Description",
          start_date: Date.current,
          end_date: Date.current + 1.month
        }
      }
    end

    assert_redirected_to challenge_url(Challenge.last)
  end

  test "should show challenge" do
    get challenge_url(@challenge)
    assert_response :success
  end

  test "should get edit when authenticated and owner" do
    sign_in @user
    get edit_challenge_url(@challenge)
    assert_response :success
  end

  test "should redirect edit when not authenticated" do
    get edit_challenge_url(@challenge)
    assert_redirected_to new_user_session_path
  end

  test "should update challenge when authenticated and owner" do
    sign_in @user
    patch challenge_url(@challenge), params: {
      challenge: { name: "Updated Title" }
    }
    assert_redirected_to challenge_url(@challenge)
  end

  # Note: destroy action not implemented in controller
  # test "should destroy challenge when authenticated and owner" do
  #   sign_in @user
  #   assert_difference("Challenge.count", -1) do
  #     delete challenge_url(@challenge)
  #   end
  #   assert_redirected_to challenges_url
  # end

  # Test spécifique pour vérifier que flash_class helper fonctionne
  test "flash messages should render without errors" do
    get challenges_url
    assert_response :success

    # Vérifier que la page contient les éléments de base
    assert_select "body"
    assert_select ".container"
  end

  # Test pour vérifier que les routes Devise sont accessibles
  test "devise routes should be accessible" do
    get new_user_session_path
    assert_response :success
  end

  # ========================================
  # TESTS DES ACTIONS DE PARTICIPATION
  # ========================================

  test "should participate in challenge when authenticated" do
    sign_in @user
    assert_difference("ChallengeParticipation.count") do
      post participate_challenge_url(@challenge)
    end
    assert_redirected_to challenge_url(@challenge)
    assert_equal "🎉 Vous participez maintenant à '#{@challenge.name}' (1/10 participants)", flash[:notice]
  end

  test "should not participate when not authenticated" do
    assert_no_difference("ChallengeParticipation.count") do
      post participate_challenge_url(@challenge)
    end
    assert_redirected_to new_user_session_path
  end

  test "should not participate when already participating" do
    sign_in @user
    # Créer une participation existante
    ChallengeParticipation.create!(user: @user, challenge: @challenge)

    assert_no_difference("ChallengeParticipation.count") do
      post participate_challenge_url(@challenge)
    end
    assert_redirected_to challenge_url(@challenge)
    assert_includes flash[:alert], "Vous participez déjà à ce challenge"
  end

  test "should not participate when challenge is full" do
    sign_in @user
    @challenge.update!(max_participants: 1)

    # Ajouter un autre participant pour remplir le challenge
    other_user = users(:two)
    ChallengeParticipation.create!(user: other_user, challenge: @challenge)

    assert_no_difference("ChallengeParticipation.count") do
      post participate_challenge_url(@challenge)
    end
    assert_redirected_to challenge_url(@challenge)
    assert_includes flash[:alert], "Ce challenge est complet"
  end

  test "should leave challenge when participating" do
    sign_in @user
    # Créer une participation
    participation = ChallengeParticipation.create!(user: @user, challenge: @challenge)

    assert_difference("ChallengeParticipation.count", -1) do
      delete leave_challenge_url(@challenge)
    end
    assert_redirected_to challenge_url(@challenge)
    assert_equal "👋 Vous avez quitté '#{@challenge.name}' (0/10 participants)", flash[:notice]
  end

  test "should not leave when not authenticated" do
    assert_no_difference("ChallengeParticipation.count") do
      delete leave_challenge_url(@challenge)
    end
    assert_redirected_to new_user_session_path
  end

  test "should not leave when not participating" do
    sign_in @user
    # Ne pas créer de participation

    assert_no_difference("ChallengeParticipation.count") do
      delete leave_challenge_url(@challenge)
    end
    assert_redirected_to challenge_url(@challenge)
    assert_includes flash[:alert], "Impossible de quitter ce challenge"
  end

  test "should handle participation errors gracefully" do
    sign_in @user
    # Simuler une erreur en rendant le challenge invalide
    @challenge.update_column(:max_participants, 0) # Contourner les validations

    assert_no_difference("ChallengeParticipation.count") do
      post participate_challenge_url(@challenge)
    end
    assert_redirected_to challenge_url(@challenge)
    assert_includes flash[:alert], "Ce challenge est complet"
  end

  # ========================================
  # TESTS D'INTÉGRATION PARTICIPATION
  # ========================================

  test "should allow multiple users to participate in same challenge" do
    sign_in @user
    user2 = users(:two)

    # Premier utilisateur participe
    assert_difference("ChallengeParticipation.count") do
      post participate_challenge_url(@challenge)
    end

    # Deuxième utilisateur participe
    sign_in user2
    assert_difference("ChallengeParticipation.count") do
      post participate_challenge_url(@challenge)
    end

    assert_equal 2, @challenge.reload.participants.count
  end

  test "should update participant count correctly" do
    sign_in @user
    assert_equal 0, @challenge.participants.count

    post participate_challenge_url(@challenge)
    assert_equal 1, @challenge.reload.participants.count

    delete leave_challenge_url(@challenge)
    assert_equal 0, @challenge.reload.participants.count
  end

  test "should send participation emails" do
    sign_in @user
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      post participate_challenge_url(@challenge)
    end
  end

  test "should send leave emails" do
    sign_in @user
    participation = ChallengeParticipation.create!(user: @user, challenge: @challenge)

    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      delete leave_challenge_url(@challenge)
    end
  end

  # ========================================
  # TESTS DE SÉCURITÉ
  # ========================================

  test "should authorize participation with Pundit" do
    sign_in @user
    # Le test vérifie que l'action est autorisée
    # Si Pundit bloque, le test échouera
    post participate_challenge_url(@challenge)
    assert_response :redirect
  end

  test "should authorize leave with Pundit" do
    sign_in @user
    participation = ChallengeParticipation.create!(user: @user, challenge: @challenge)

    delete leave_challenge_url(@challenge)
    assert_response :redirect
  end
end
