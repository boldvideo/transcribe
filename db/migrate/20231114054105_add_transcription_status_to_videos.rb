class AddTranscriptionStatusToVideos < ActiveRecord::Migration[7.1]
  def change
    add_column :videos, :transcription_status, :string
  end
end
