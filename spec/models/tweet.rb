class Tweet < ActiveRecord::Base
  has_many :favorites
  has_many :active_favorites,
           -> { active }, class_name: "Favorite", inverse_of: :tweet
end
