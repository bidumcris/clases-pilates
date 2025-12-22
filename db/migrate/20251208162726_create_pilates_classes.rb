class CreatePilatesClasses < ActiveRecord::Migration[8.0]
  def change
    create_table :pilates_classes do |t|
      t.string :name
      t.integer :level
      t.references :room, null: false, foreign_key: true
      t.references :instructor, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.integer :max_capacity

      t.timestamps
    end
  end
end
