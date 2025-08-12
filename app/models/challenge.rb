class Challenge < ApplicationRecord
  belongs_to :user
  has_many :challenge_participations, dependent: :destroy
  has_many :participants, through: :challenge_participations, source: :user

  validates :name, presence: true
  validates :description, presence: true, length: { minimum: 5, maximum: 500 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  scope :with_participants, -> { includes(:participants) }

  def available_spots
    10 - participants.count
  end

  def full?
    participants.count >= 10
  end

  def can_participate?(user)
    return false unless user
    return false if self.user == user # Cannot participate in own challenge
    return false if full? # Challenge is full
    return false if participants.include?(user) # Already participating
    true
  end

  def participation_status_for(user)
    return :not_logged_in unless user
    return :own_challenge if self.user == user
    return :full if full?
    return :already_participating if participants.include?(user)
    :can_participate
  end

  private

  def end_date_after_start_date
    if end_date.present? && start_date.present? && end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
