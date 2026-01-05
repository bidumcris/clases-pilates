class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :role, :integer, default: 0, null: false

    # Backfill: los usuarios que hoy son admin por `level` pasan a role:admin
    execute <<~SQL.squish
      UPDATE users
      SET role = 2
      WHERE level = 4
    SQL
  end

  def down
    remove_column :users, :role
  end
end


