class MigratePaymentMethodsToCashbox < ActiveRecord::Migration[8.0]
  def up
    # payment_method era:
    # 0=card, 1=qr, 2=deposit
    #
    # Nuevo payment_method:
    # 0=efectivo, 1=debito, 2=credito, 3=transferencia
    #
    # Migración de equivalencias:
    # - card -> credito
    # - qr -> transferencia
    # - deposit (seña) -> transferencia
    execute <<~SQL.squish
      UPDATE payments
      SET payment_method =
        CASE payment_method
          WHEN 0 THEN 2
          WHEN 1 THEN 3
          WHEN 2 THEN 3
          ELSE payment_method
        END
    SQL
  end

  def down
    # No revertimos automáticamente: se perdería la distinción entre métodos nuevos.
  end
end


