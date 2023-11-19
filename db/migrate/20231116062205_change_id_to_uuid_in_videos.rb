class ChangeIdToUuidInVideos < ActiveRecord::Migration[7.1]
  def change
    add_column :videos, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    rename_column :videos, :id, :integer_id
    rename_column :videos, :uuid, :id
    execute 'ALTER TABLE videos DROP CONSTRAINT videos_pkey;'
    execute 'ALTER TABLE videos ADD PRIMARY KEY (id);'
    remove_column :videos, :integer_id
  end
end
