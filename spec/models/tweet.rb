class Tweet < ActiveRecord::Base
  has_many :favorites
  has_many :active_favorites,
           -> { active }, class_name: "Favorite", inverse_of: :tweet
  has_many :another_associated_favorites,
           primary_key: :another_id, foreign_key: :another_id,
           class_name: "Favorite", inverse_of: :another_associated_tweet
end
