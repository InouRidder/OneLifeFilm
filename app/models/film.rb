class Film < ApplicationRecord

  validates :name, presence: true
  validates :video_url, presence: true
  validates :slug, presence: true, uniqueness: true

  extend FriendlyId
  friendly_id :name, use: :slugged

end
