class AddTranscriptUrlsToVideo < ActiveRecord::Migration[7.1]
  def change

    add_column :videos, :json_transcription_url, :string
    add_column :videos, :webvtt_url, :string
    add_column :videos, :srt_url, :string

  end
end
