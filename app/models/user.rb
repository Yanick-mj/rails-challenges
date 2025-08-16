class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :challenges, dependent: :nullify
  has_many :challenge_participations, dependent: :destroy
  has_many :participated_challenges, through: :challenge_participations, source: :challenge

  # Association pour la photo de profil
  has_one_attached :avatar

  # Validations pour l'avatar
  validate :acceptable_avatar

  # Callbacks pour les notifications
  after_commit :send_welcome_email, on: :create

  # Méthode pour obtenir le nom complet
  def name
    if first_name.present? && last_name.present?
      "#{first_name} #{last_name}"
    elsif first_name.present?
      first_name
    elsif last_name.present?
      last_name
    else
      nil
    end
  end

  private

  def send_welcome_email
    NotificationMailer.welcome_email(self).deliver_later
  end

  def acceptable_avatar
    return unless avatar.attached?

    unless avatar.blob.byte_size <= 5.megabytes
      errors.add(:avatar, "est trop volumineux (5MB maximum)")
    end

    acceptable_types = [ "image/png", "image/jpeg", "image/jpg" ]
    unless acceptable_types.include?(avatar.content_type)
      errors.add(:avatar, "doit être une image PNG, JPEG ou JPG")
    end
  end
end
