class AddWeeklyDaysToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :weekly_days, :integer, array: true, default: [], null: false
    add_index :users, :weekly_days
  end
end

