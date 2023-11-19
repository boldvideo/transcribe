class AddMuxFieldsToVideos < ActiveRecord::Migration[7.1]
  def change
    add_column :videos, :mux_asset_id, :string
    add_column :videos, :playback_id, :string
    add_column :videos, :status, :string
  end
end
