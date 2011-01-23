ActiveRecord::Schema.define do
  create_table :artists, :force => true do |t|
    t.string :name
  end
end
