ActiveRecord::Schema.define do
  create_table :artists, :force => true do |t|
    t.timestamps
    t.string :name
  end
  add_index :artists, :name
  
  create_table :artists_users, :force => true, :id => false do |t|
    t.integer :artist_id
    t.integer :user_id
  end
  add_index :artists_users, :artist_id
  add_index :artists_users, :user_id
  
  create_table :statistics, :force => true do |t|
    t.timestamps
    t.belongs_to :artist
    t.string     :name
    t.float      :value
  end
  add_index :statistics, [:artist_id, :name]
  
  create_table :users, :force => true do |t|
    t.timestamps
    t.string :lastfm_username
  end
  add_index :users, :lastfm_username
end
