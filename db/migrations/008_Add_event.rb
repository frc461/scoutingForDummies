Sequel.migration do
  change do
    add_column :notes, :event_id, Integer
  end
end