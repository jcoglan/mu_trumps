ActiveRecord::Schema.define do
  create_table :artists, :force => true do |t|
    t.timestamps
    t.string :name
    t.string :image_url
  end
  add_index :artists, :name
  
  create_table :artists_users, :force => true, :id => false do |t|
    t.integer :artist_id
    t.integer :user_id
  end
  add_index :artists_users, :artist_id
  add_index :artists_users, :user_id
  
  create_table :cards, :force => true do |t|
    t.timestamps
    t.belongs_to :artist
    t.belongs_to :game
    t.belongs_to :user
    t.integer    :position
  end
  add_index :cards, [:game_id, :position]
  
  create_table :games, :force => true do |t|
    t.timestamps
    t.belongs_to :current_user
    t.string     :current_stat
  end
  
  create_table :games_users, :force => true, :id => false do |t|
    t.integer :game_id
    t.integer :user_id
  end
  add_index :games_users, :game_id
  add_index :games_users, :user_id
  
  create_table :statistics, :force => true do |t|
    t.timestamps
    t.belongs_to :artist
    t.string     :name
    t.float      :value
  end
  add_index :statistics, [:artist_id, :name]
  
  create_table :identifiers, :force => true do |t|
    t.timestamps
    t.belongs_to :artist
    t.string     :name
    t.string     :value
  end
  add_index :identifiers, [:artist_id, :name]

  create_table :users, :force => true do |t|
    t.timestamps
    t.string :lastfm_username
  end
  add_index :users, :lastfm_username
end
