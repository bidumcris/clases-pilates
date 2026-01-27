class AddTagsToPilatesClasses < ActiveRecord::Migration[8.0]
  def change
    add_column :pilates_classes, :tags, :string
    add_index :pilates_classes, :tags
  end
end

