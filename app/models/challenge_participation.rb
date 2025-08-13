class ChallengeParticipation < ApplicationRecord
  belongs_to :challenge
  belongs_to :user

  # Validations
  validates :challenge_id, uniqueness: { scope: :user_id, message: "Vous participez déjà à ce challenge" }
  validate :challenge_not_full

  private

  def challenge_not_full
    if challenge.participants.count >= 10
      errors.add(:base, "Ce challenge est complet (10 participants maximum)")
    end
  end
end
