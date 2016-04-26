class EditArtistsTable < ActiveRecord::Migration
  def change
    rename_column :artists, :image_discogs, :discogs_image
    rename_column :artists, :image_lastfm, :lastfm_image
    add_column :artists, :total_words, :integer, default: 0, null: false
  end
end
