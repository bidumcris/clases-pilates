class AddClassTypeToPilatesClasses < ActiveRecord::Migration[8.0]
  def change
    add_column :pilates_classes, :class_type, :integer, default: 0, null: false
    # 0 = grupal, 1 = privada
  end
end
