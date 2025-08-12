class ChallengeParticipation < ApplicationRecord
  belongs_to :challenge
  belongs_to :user

  validates :user_id, uniqueness: { scope: :challenge_id, message: "already participating in this challenge" }
  validate :challenge_not_full
  validate :user_not_challenge_creator
  validate :challenge_has_available_spots

  private

  def challenge_not_full
    errors.add(:challenge, "is already full") if challenge&.full?
  end

  def user_not_challenge_creator
    errors.add(:user, "cannot participate in their own challenge") if user == challenge&.user
  end

  def challenge_has_available_spots
    return unless challenge

    if challenge.challenge_participations.count >= 10
      errors.add(:challenge, "has reached maximum participants (10)")
    end
  end
end