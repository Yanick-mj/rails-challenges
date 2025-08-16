require "test_helper"

class UserTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @user = User.new(
      email: "test@example.com",
      password: "password123",
      first_name: "John",
      last_name: "Doe"
    )

    # Configurer l'adaptateur de test pour ActiveJob
    ActiveJob::Base.queue_adapter = :test
  end

  # ========================================
  # TESTS DE VALIDATION
  # ========================================

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "should require valid email format" do
    @user.email = "invalid-email"
    assert_not @user.valid?
    assert_includes @user.errors[:email], "is invalid"
  end

  test "should require unique email" do
    @user.save!
    duplicate_user = User.new(
      email: @user.email,
      password: "password123"
    )
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "should require password" do
    @user.password = nil
    assert_not @user.valid?
    assert_includes @user.errors[:password], "can't be blank"
  end

  test "should require password with minimum length" do
    @user.password = "12345"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "is too short (minimum is 6 characters)"
  end

  # ========================================
  # TESTS DES MÉTHODES
  # ========================================

  test "should return full name when first_name and last_name present" do
    @user.first_name = "John"
    @user.last_name = "Doe"
    assert_equal "John Doe", @user.name
  end

  test "should return first_name when only first_name present" do
    @user.first_name = "John"
    @user.last_name = nil
    assert_equal "John", @user.name
  end

  test "should return last_name when only last_name present" do
    @user.first_name = nil
    @user.last_name = "Doe"
    assert_equal "Doe", @user.name
  end

  test "should return nil when no name present" do
    @user.first_name = nil
    @user.last_name = nil
    assert_nil @user.name
  end

  # ========================================
  # TESTS DES CALLBACKS
  # ========================================

  test "should send welcome email after creation" do
    assert_enqueued_with(job: ActionMailer::MailDeliveryJob) do
      @user.save!
    end
  end

  # ========================================
  # TESTS DES ASSOCIATIONS
  # ========================================

  test "should have many challenges" do
    assert_respond_to @user, :challenges
  end

  test "should have many challenge participations" do
    assert_respond_to @user, :challenge_participations
  end

  test "should have many participated challenges" do
    assert_respond_to @user, :participated_challenges
  end

  test "should have one avatar" do
    assert_respond_to @user, :avatar
  end

  # ========================================
  # TESTS DE VALIDATION AVATAR
  # ========================================

  test "should accept valid avatar file types" do
    # Simuler un avatar valide
    @user.avatar.attach(
      io: StringIO.new("fake image content"),
      filename: "test.jpg",
      content_type: "image/jpeg"
    )
    assert @user.valid?
  end

  test "should reject invalid avatar file types" do
    @user.avatar.attach(
      io: StringIO.new("fake file content"),
      filename: "test.txt",
      content_type: "text/plain"
    )
    assert_not @user.valid?
    assert_includes @user.errors[:avatar], "doit être une image PNG, JPEG ou JPG"
  end

  test "should reject avatar files that are too large" do
    # Simuler un fichier trop volumineux (6MB)
    large_content = "x" * (6.megabytes + 1)
    @user.avatar.attach(
      io: StringIO.new(large_content),
      filename: "large.jpg",
      content_type: "image/jpeg"
    )
    assert_not @user.valid?
    assert_includes @user.errors[:avatar], "est trop volumineux (5MB maximum)"
  end

  # ========================================
  # TESTS DEVISE
  # ========================================

  test "should be database authenticatable" do
    assert User.devise_modules.include?(:database_authenticatable)
  end

  test "should be registerable" do
    assert User.devise_modules.include?(:registerable)
  end

  test "should be recoverable" do
    assert User.devise_modules.include?(:recoverable)
  end

  test "should be rememberable" do
    assert User.devise_modules.include?(:rememberable)
  end

  test "should be validatable" do
    assert User.devise_modules.include?(:validatable)
  end
end
