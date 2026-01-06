class AddContactFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :dni, :string
    add_column :users, :phone, :string
    add_column :users, :mobile, :string

    add_index :users, :dni, unique: true
  end
end


