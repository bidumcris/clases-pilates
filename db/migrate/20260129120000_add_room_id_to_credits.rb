# frozen_string_literal: true

class AddRoomIdToCredits < ActiveRecord::Migration[8.0]
  def change
    add_reference :credits, :room, null: true, foreign_key: true
  end
end
