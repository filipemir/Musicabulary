class AddWordiness < ActiveRecord::Migration
  def change
    add_column :artists, :wordiness, :integer
  end
end
