class AddUserIdToInstructors < ActiveRecord::Migration[8.0]
  def change
    add_reference :instructors, :user, null: true, foreign_key: true, index: { unique: true }
  end
end


