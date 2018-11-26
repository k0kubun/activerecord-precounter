class Favorite < ActiveRecord::Base
  belongs_to :tweet
  belongs_to :another_associated_tweet,
             primary_key: :another_id, foreign_key: :another_id,
             class_name: "Tweet"

  scope :active, -> { where(active: true) }
end
