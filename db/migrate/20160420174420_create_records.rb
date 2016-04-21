class CreateRecords < ActiveRecord::Migration
  def change
    create_table :records do |t|
      t.belongs_to :artist, null: false
      t.string :title, default: '', null: false
      t.integer :discogs_id
      t.integer :year, null: false
      t.timestamps null: false
    end

    add_index :records, [:artist_id, :title, :year], unique: true
  end
end
