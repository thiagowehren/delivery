class AddExpirationToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :expires_at, :datetime
    add_column :products, :expired, :boolean, default: false
  end
end
