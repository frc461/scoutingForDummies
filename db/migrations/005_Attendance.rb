Sequel.migration do
  change do
    create_table(:attendance) do
      foreign_key :team_id, :teams, null: false
      foreign_key :event_id, :events, null: false
    end
  end
end