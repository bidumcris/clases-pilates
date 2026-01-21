class AddMercadoPagoFieldsToPayments < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :provider, :string
    add_column :payments, :provider_reference, :string
    add_column :payments, :checkout_url, :string
    add_column :payments, :paid_at, :datetime
    add_column :payments, :provider_payload, :jsonb, default: {}, null: false

    add_index :payments, [ :provider, :provider_reference ]
    add_index :payments, :paid_at
  end
end

