ActiveRecord::Schema.define do
  create_table :favorites, force: true do |t|
    t.integer  :tweet_id
    t.integer  :another_id
    t.boolean :active
    t.timestamps null: false
  end
  add_index :favorites, :tweet_id
  add_index :favorites, :another_id

  create_table :tweets, force: true do |t|
    t.integer  :another_id
    t.timestamps null: false
  end
  add_index :tweets, :another_id, unique: true
end
