class ConvertAdminLevelToRole < ActiveRecord::Migration[8.0]
  def up
    # Si existían usuarios con level=4 (antiguo "admin"), los normalizamos:
    # - role => admin
    # - level => advanced (para mantener un valor válido en el enum de nivel)
    execute <<~SQL.squish
      UPDATE users
      SET role = 2, level = 3
      WHERE level = 4
    SQL
  end

  def down
    # No revertimos automáticamente porque "admin" ya no existe en el enum de level.
  end
end


