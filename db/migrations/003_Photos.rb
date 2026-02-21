Sequel.migration do
  change do
    create_table(:photos) do
      primary_key :id
      String :filename, null: false
      Integer :team_number, null: false
    end
  end
end