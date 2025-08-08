class Challenge < ApplicationRecord
  validates :name, presence: true
  validates :description, presence: true, length: { minimum: 5, maximum: 500 }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_after_start_date



  private
  def end_date_after_start_date
    if end_date.present? && start_date.present? && end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end
end
