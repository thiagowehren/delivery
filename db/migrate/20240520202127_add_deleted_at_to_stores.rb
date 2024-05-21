class AddDeletedAtToStores < ActiveRecord::Migration[7.1]
  def change
    add_column :stores, :deleted_at, :datetime
    add_index :stores, :deleted_at
  end
end
