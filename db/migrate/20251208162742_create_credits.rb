class CreateCredits < ActiveRecord::Migration[8.0]
  def change
    create_table :credits do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount, null: false
      t.date :expires_at, null: false
      t.boolean :used, default: false, null: false

      t.timestamps
    end
  end
end
