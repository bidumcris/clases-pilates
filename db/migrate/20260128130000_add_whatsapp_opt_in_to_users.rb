class AddWhatsappOptInToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :whatsapp_opt_in, :boolean, default: false, null: false
    add_column :users, :whatsapp_opt_in_at, :datetime
    add_column :users, :whatsapp_opt_in_source, :string

    add_index :users, :whatsapp_opt_in
    add_index :users, :whatsapp_opt_in_at
  end
end

