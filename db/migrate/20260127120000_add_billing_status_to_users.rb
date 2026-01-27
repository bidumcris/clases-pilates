class AddBillingStatusToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :billing_status, :integer, null: false, default: 1
    add_index :users, :billing_status
  end
end

