class Management::RoomsController < Management::BaseController
  before_action :ensure_admin!
  before_action :set_room, only: [ :edit, :update ]

  def edit
  end

  def update
    if @room.update(room_params)
      redirect_to edit_management_room_path(@room), notice: "Servicio actualizado correctamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_room
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(
      :service_kind,
      :service_name,
      :service_description,
      :service_notice,
      :service_schedule_description,
      :service_slot_interval_minutes,
      :service_duration_minutes,
      :service_reserved_fixed_slots,
      :service_daily_free_limit,
      :service_weekly_free_limit,
      :service_daily_active_limit,
      :service_weekly_active_limit,
      :service_max_days_in_advance
    )
  end
end
