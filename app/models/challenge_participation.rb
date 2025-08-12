class ChallengeParticipation < ApplicationRecord
  belongs_to :challenge
  belongs_to :user

  # Validations
  validates :challenge_id, uniqueness: { scope: :user_id, message: "Vous participez déjà à ce challenge" }
  validate :user_cannot_participate_in_own_challenge
  validate :challenge_not_full

  private

  def user_cannot_participate_in_own_challenge
    if challenge.user_id == user_id
      errors.add(:base, "Vous ne pouvez pas participer à votre propre challenge")
    end
  end

  def challenge_not_full
    if challenge.participants.count >= 10
      errors.add(:base, "Ce challenge est complet (10 participants maximum)")
    end
  end
end
