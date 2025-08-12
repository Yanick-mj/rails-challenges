require "test_helper"

class ChallengesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get challenges_url
    assert_response :success
    assert_select "h1", "Challenges"
  end

  test "should get new" do
    get new_challenge_url
    assert_response :success
  end

  test "should create challenge" do
    assert_difference("Challenge.count") do
      post challenges_url, params: { challenge: { title: "Test Challenge", description: "Test Description" } }
    end

    assert_redirected_to challenge_url(Challenge.last)
  end

  test "should show challenge" do
    challenge = challenges(:one)
    get challenge_url(challenge)
    assert_response :success
  end

  test "should get edit" do
    challenge = challenges(:one)
    get edit_challenge_url(challenge)
    assert_response :success
  end

  test "should update challenge" do
    challenge = challenges(:one)
    patch challenge_url(challenge), params: { challenge: { title: "Updated Title" } }
    assert_redirected_to challenge_url(challenge)
  end

  test "should destroy challenge" do
    challenge = challenges(:one)
    assert_difference("Challenge.count", -1) do
      delete challenge_url(challenge)
    end

    assert_redirected_to challenges_url
  end

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
end
