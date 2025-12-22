class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pilates_class, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.datetime :reserved_at, null: false

      t.timestamps
    end
  end
end
