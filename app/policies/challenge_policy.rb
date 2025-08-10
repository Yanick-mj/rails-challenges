class ChallengePolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    # Minimal: tout le monde peut voir la liste des challenges
    def resolve
      scope.all
    end
  end
  def show?
    true
  end
  def create?
    user.present?
  end
  def update?
    user.present? && record.user == user
  end
  def edit?
    user.present? && record.user == user
  end
end
