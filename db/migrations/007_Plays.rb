Sequel.migration do
  change do
    create_table(:plays) do
      primary_key :id
      Integer :match_id, null: false
      Integer :team_number, null: false
      String :epa, null: false
    end
  end
end