Sequel.migration do
  change do
    create_table(:plays) do
      primary_key :id
      String :match_code, null: false
      Integer :team_number, null: false
      String :alliance, null: false
      String :epa, null: false
    end
  end
end