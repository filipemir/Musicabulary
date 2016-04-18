class AddUserInfo < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :image, :string
    add_column :users, :playcount, :integer
  end
end
