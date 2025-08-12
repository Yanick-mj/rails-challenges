class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :challenges, dependent: :destroy
  has_many :challenge_participations, dependent: :destroy
  has_many :participated_challenges, through: :challenge_participations, source: :challenge

  validates :first_name, presence: true
  validates :last_name, presence: true

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def can_participate_in?(challenge)
    return false if challenge.user == self # Cannot participate in own challenge
    return false if challenge.full? # Challenge is full
    return false if participated_challenges.include?(challenge) # Already participating
    true
  end
end