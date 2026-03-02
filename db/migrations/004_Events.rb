Sequel.migration do
  change do
    create_table(:events) do
      primary_key :id
      String :name, null: false
      String :code, null: false
    end
  end
end