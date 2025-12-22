class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.string :name
      t.integer :room_type
      t.integer :capacity

      t.timestamps
    end
  end
end
