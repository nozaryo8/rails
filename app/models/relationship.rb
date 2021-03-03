class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  # Relationshipとfollowerは1対1の関係にある　クラスはUser
  validates :follower_id, presence: true
  # Relationshipとfollowedは1対1の関係にある　クラスはUser
  validates :followed_id, presence: true
end
