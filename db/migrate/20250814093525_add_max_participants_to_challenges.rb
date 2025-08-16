class AddMaxParticipantsToChallenges < ActiveRecord::Migration[8.0]
  def change
    add_column :challenges, :max_participants, :integer, default: 10, null: false
  end
end
