class CreateSongs < ActiveRecord::Migration
  def change
    create_table :songs do |t|
      t.belongs_to :record, null: false
      t.string :title, default: '', null: false
      t.text :lyrics
      t.timestamps null: false
    end

    add_index :songs, [:record_id, :title], unique: true
  end
end
