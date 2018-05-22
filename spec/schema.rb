ActiveRecord::Schema.define do
  create_table :favorites, force: true do |t|
    t.integer  :tweet_id
    t.boolean :active
    t.timestamps null: false
  end
  add_index :favorites, :tweet_id

  create_table :tweets, force: true do |t|
    t.timestamps null: false
  end
end
