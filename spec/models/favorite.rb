class Favorite < ActiveRecord::Base
  belongs_to :tweet
  scope :active, -> { where(active: true) }
end
