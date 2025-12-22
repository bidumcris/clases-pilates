class CreateRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :pilates_class, null: false, foreign_key: true
      t.integer :request_type, default: 0, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
