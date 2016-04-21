class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.belongs_to :user, null: false
      t.references :artist, null: false
      t.string :timeframe, default: '', null: false
      t.integer :rank, default: '', null: false
      t.integer :playcount
      t.timestamps null: false
    end

    add_index :favorites, [:user_id, :artist_id, :timeframe], unique: true
  end
end
