class AddSubscriptionFieldsToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :kind, :integer, null: false, default: 0
    add_column :payments, :due_date, :date
    add_column :payments, :period_start, :date
    add_column :payments, :period_end, :date
    add_column :payments, :turns_included, :integer
    add_column :payments, :notes, :string

    add_index :payments, :kind
    add_index :payments, :due_date
    add_index :payments, [ :user_id, :kind, :period_start, :period_end ], unique: true, name: "idx_payments_unique_period"
  end
end

