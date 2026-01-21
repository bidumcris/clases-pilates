class AddHolidayToPilatesClasses < ActiveRecord::Migration[8.0]
  def change
    add_column :pilates_classes, :holiday, :boolean, null: false, default: false
    add_column :pilates_classes, :holiday_reason, :string
    add_index :pilates_classes, :holiday
  end
end

