class Video < ApplicationRecord
  has_one_attached :file
  validates :mux_asset_id, presence: true, on: :update
end
