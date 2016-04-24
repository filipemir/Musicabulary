class AddArtistPicture < ActiveRecord::Migration
  def change
    add_column :artists, :image_discogs, :string
    add_column :artists, :image_lastfm, :string
  end
end
