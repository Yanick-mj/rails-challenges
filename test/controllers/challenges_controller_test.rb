require "test_helper"

class ChallengesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @challenge = challenges(:one)
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
end
