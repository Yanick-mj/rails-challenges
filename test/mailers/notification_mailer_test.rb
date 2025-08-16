require "test_helper"

class NotificationMailerTest < ActionMailer::TestCase
  test "welcome email" do
    user = users(:one)
    email = NotificationMailer.welcome_email(user)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["from@example.com"], email.from
    assert_equal [user.email], email.to
    assert_equal "Bienvenue sur Rails Challenge !", email.subject
  end

  test "challenge created email" do
    user = users(:one)
    challenge = challenges(:one)
    email = NotificationMailer.challenge_created_email(user, challenge)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["from@example.com"], email.from
    assert_equal [user.email], email.to
    assert_equal "Votre challenge '#{challenge.name}' a été créé avec succès !", email.subject
  end

  test "participation email - joined" do
    user = users(:one)
    challenge = challenges(:one)
    email = NotificationMailer.participation_email(user, challenge, 'joined')

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["from@example.com"], email.from
    assert_equal [user.email], email.to
    assert_equal "Vous avez rejoint le challenge '#{challenge.name}' !", email.subject
  end

  test "participation email - left" do
    user = users(:one)
    challenge = challenges(:one)
    email = NotificationMailer.participation_email(user, challenge, 'left')

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal ["from@example.com"], email.from
    assert_equal [user.email], email.to
    assert_equal "Vous avez quitté le challenge '#{challenge.name}'", email.subject
  end
end
