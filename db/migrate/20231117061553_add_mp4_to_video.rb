class AddMp4ToVideo < ActiveRecord::Migration[7.1]
  def change
    add_column :videos, :mp4_filename, :string
    add_column :videos, :mp4_url, :string
  end
end
