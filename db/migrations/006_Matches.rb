Sequel.migration do
  change do
    create_table(:matches) do
      primary_key :id
      String :code, null: false
      Time :time, null: false
      Integer :event_id, null: false
      String :status, null: false
      String :prediction
      String :real_results
    end
  end
end