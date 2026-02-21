Sequel.migration do
  change do
    create_table(:notes) do
      primary_key :id
      String :content, null: false, text:true
      Integer :team_number, null: false
    end
  end
end