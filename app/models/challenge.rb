class Challenge < ApplicationRecord
  belongs_to :user, optional: true
  has_many :challenge_participations, dependent: :destroy
  has_many :participants, through: :challenge_participations, source: :user

  validates :name, presence: true
  validates :description, presence: true, length: { minimum: 5, maximum: 500 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :max_participants, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validate :end_date_after_start_date
  validate :start_date_cannot_be_in_past, on: :create
  validate :max_participants_cannot_be_less_than_current_participants, on: :update

  # Callbacks pour les notifications
  after_commit :send_challenge_created_email, on: :create

  # Scopes pour le tri
  scope :ordered_by_start_date, -> { order(:start_date) }
  scope :ordered_by_start_date_desc, -> { order(start_date: :desc) }
  scope :upcoming, -> { where("start_date >= ?", Date.current).order(:start_date) }
  scope :active, -> { where("start_date <= ? AND end_date >= ?", Date.current, Date.current) }

  # Méthodes pour la participation
  def available_spots
    max_participants - participants.count
  end

  def full?
    participants.count >= max_participants
  end

  def can_participate?(user)
    return false unless user
    return false if full?
    return false if participants.include?(user)
    true
  end

  private

  def send_challenge_created_email
    return unless user # Envoyer seulement si le challenge a un créateur
    NotificationMailer.challenge_created_email(user, self).deliver_later
  end

  def end_date_after_start_date
    if end_date.present? && start_date.present? && end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end

  def start_date_cannot_be_in_past
    if start_date.present? && start_date < Date.current
      errors.add(:start_date, "ne peut pas être dans le passé")
    end
  end

  def max_participants_cannot_be_less_than_current_participants
    if max_participants.present? && participants.count > max_participants
      errors.add(:max_participants, "ne peut pas être inférieur au nombre actuel de participants (#{participants.count})")
    end
  end
end
