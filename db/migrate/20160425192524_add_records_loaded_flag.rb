class AddRecordsLoadedFlag < ActiveRecord::Migration
  def change
    add_column :artists, :records_loaded, :boolean, default: false, null: false
  end
end
