class AddSongPosition < ActiveRecord::Migration
  def change
    add_column :songs, :position, :string, default: ''
  end
end
