class UpdateUserLevels < ActiveRecord::Migration[8.0]
  def up
    # Actualizar los niveles existentes:
    # basic (0) -> basic (1)
    # intermediate (1) -> intermediate (2)
    # advanced (2) -> advanced (3)
    # admin (3) -> admin (4)

    # Primero, cambiar admin a un valor temporal (99)
    execute "UPDATE users SET level = 99 WHERE level = 3"

    # Luego actualizar los demás niveles
    execute "UPDATE users SET level = level + 1 WHERE level < 99"

    # Finalmente, cambiar admin de vuelta a 4
    execute "UPDATE users SET level = 4 WHERE level = 99"

    # Ahora inicial será 0 (por defecto)
  end

  def down
    # Revertir los cambios
    execute "UPDATE users SET level = level - 1 WHERE level > 0 AND level < 4"
    execute "UPDATE users SET level = 3 WHERE level = 4"
  end
end
