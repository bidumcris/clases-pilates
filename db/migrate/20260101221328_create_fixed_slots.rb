class CreateFixedSlots < ActiveRecord::Migration[8.0]
  def change
    create_table :fixed_slots do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :day_of_week, null: false # 0 = domingo, 1 = lunes, ..., 6 = sábado
      t.integer :hour, null: false # Hora en formato 24h (ej: 9, 10, 17)
      t.references :room, null: false, foreign_key: true
      t.references :instructor, null: false, foreign_key: true
      t.string :level, null: false
      t.integer :status, default: 0, null: false # 0 = activo, 1 = pausado, 2 = cancelado

      t.timestamps
    end

    add_index :fixed_slots, [ :user_id, :day_of_week, :hour ], unique: true
  end
end
