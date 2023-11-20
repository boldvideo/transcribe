class Video < ApplicationRecord
  # after_update_commit :broadcast_changes

  has_one_attached :file
  validates :mux_asset_id, presence: true, on: :update

  # def broadcast_changes
  #   broadcast_replace_to self, target: "video_player", partial: 'videos/video_player'
  #   broadcast_replace_to self, target: "transcription_status", partial: 'videos/transcription_status'
  # end
end
