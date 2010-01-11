ActiveRecord::Schema.define(:version => 0) do
  create_table :users, :force => true do |t|
    t.string :type
    t.string :name
    t.text :contacts
  end
end
