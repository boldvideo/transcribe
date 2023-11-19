class AddTranscriptRequestIdToVideo < ActiveRecord::Migration[7.1]
  def change
    add_column :videos, :transcript_request_id, :string
  end
end
