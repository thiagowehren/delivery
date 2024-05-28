class AddHiddenToProductsAndStores < ActiveRecord::Migration[7.1]
  def change
    add_column :stores, :hidden, :boolean, default: false
    add_column :products, :hidden, :boolean, default: false
  end
end
