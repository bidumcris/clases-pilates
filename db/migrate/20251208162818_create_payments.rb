class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :payment_method, default: 0, null: false
      t.integer :payment_status, default: 0, null: false
      t.string :transaction_id

      t.timestamps
    end
  end
end
