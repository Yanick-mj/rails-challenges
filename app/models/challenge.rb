class Challenge < ApplicationRecord
  belongs_to :user, optional: true
  validates :name, presence: true
  validates :description, presence: true, length: { minimum: 5, maximum: 500 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date

  # Scopes pour le tri
  scope :ordered_by_start_date, -> { order(:start_date) }
  scope :ordered_by_start_date_desc, -> { order(start_date: :desc) }
  scope :upcoming, -> { where("start_date >= ?", Date.current).order(:start_date) }
  scope :active, -> { where("start_date <= ? AND end_date >= ?", Date.current, Date.current) }

  private
  def end_date_after_start_date
    if end_date.present? && start_date.present? && end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
