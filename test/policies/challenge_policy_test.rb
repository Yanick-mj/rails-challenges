require 'test_helper'

class ChallengePolicyTest < ActiveSupport::TestCase
  def setup
    @now = Date.current
    @challenge1 = Challenge.create!(
      name: "C1", description: "desc 12345", start_date: @now, end_date: @now + 1.day
    )
    @challenge2 = Challenge.create!(
      name: "C2", description: "desc 67890", start_date: @now + 1.day, end_date: @now + 2.days
    )
  end

  def test_scope_returns_all_records
    any_user = users(:one)
    scope = Pundit.policy_scope!(any_user, Challenge)
    assert_equal Challenge.all.sort_by(&:id), scope.sort_by(&:id)
  end

  def test_show_is_public
    assert ChallengePolicy.new(nil, @challenge1).show?
    assert ChallengePolicy.new(users(:one), @challenge1).show?
  end

  def test_create_requires_authenticated_user
    refute ChallengePolicy.new(nil, Challenge.new).create?
    assert ChallengePolicy.new(users(:one), Challenge.new).create?
  end

  def test_update_only_owner
    owner = users(:one)
    other = users(:two)
    record = Challenge.new(name: "Owned", description: "abcdef", start_date: @now, end_date: @now + 1.day)
    record.user = owner

    assert ChallengePolicy.new(owner, record).update?
    refute ChallengePolicy.new(other, record).update?
    refute ChallengePolicy.new(nil, record).update?
  end
end
