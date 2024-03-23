class AddRoleToUsers < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:users, :role)
      add_column :users, :role, :integer
    end
  end
end
