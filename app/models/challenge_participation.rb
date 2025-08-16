class ChallengeParticipation < ApplicationRecord
  belongs_to :challenge
  belongs_to :user

  # Validations
  validates :challenge_id, uniqueness: { scope: :user_id, message: "Vous participez déjà à ce challenge" }
  validate :challenge_not_full

  # Callbacks pour les notifications
  after_commit :send_joined_email, on: :create
  after_commit :send_left_email, on: :destroy

  private

  def send_joined_email
    NotificationMailer.participation_email(user, challenge, "joined").deliver_later
  end

  def send_left_email
    NotificationMailer.participation_email(user, challenge, "left").deliver_later
  end

  def challenge_not_full
    if challenge.participants.count >= challenge.max_participants
      errors.add(:base, "Ce challenge est complet (#{challenge.max_participants} participants maximum)")
    end
  end
end
