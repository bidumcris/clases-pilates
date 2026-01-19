class AddAdminFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.string :name
      t.boolean :active, default: true, null: false
      t.boolean :fake_email, default: false, null: false

      t.date :subscription_start
      t.date :subscription_end

      t.string :emergency_phone
      t.text :additional_info

      t.decimal :payment_amount, precision: 10, scale: 2
      t.decimal :debt_amount, precision: 10, scale: 2
      t.date :last_payment_date

      t.integer :monthly_turns
      t.date :join_date
      t.date :first_payment_date
      t.integer :payments_count

      t.boolean :normal_view, default: true, null: false
      t.string :param1
      t.string :param2
      t.string :param3
    end
  end
end

