class AddServiceFieldsToRooms < ActiveRecord::Migration[8.0]
  def change
    change_table :rooms, bulk: true do |t|
      t.string  :service_kind
      t.string  :service_name
      t.text    :service_description
      t.text    :service_notice
      t.text    :service_schedule_description
      t.integer :service_slot_interval_minutes
      t.integer :service_duration_minutes
      t.integer :service_reserved_fixed_slots
      t.integer :service_daily_free_limit
      t.integer :service_weekly_free_limit
      t.integer :service_daily_active_limit
      t.integer :service_weekly_active_limit
      t.integer :service_max_days_in_advance
    end
  end
end
