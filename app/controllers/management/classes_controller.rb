class Management::ClassesController < Management::BaseController
  before_action :set_pilates_class, only: [ :show, :edit, :update, :destroy ]
  before_action :set_pilates_class, only: [ :edit, :update, :destroy ]
  before_action :ensure_admin!, only: [ :new, :create, :edit, :update, :destroy ]

  def index
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @week_start = @date.beginning_of_week(:monday)
    @week_end = @week_start + 6.days

    @classes = PilatesClass.where("DATE(start_time) >= ? AND DATE(start_time) <= ?", @week_start, @week_end)
                           .order(start_time: :asc)
    @classes_by_day = @classes.group_by { |c| c.start_time.to_date }

    @rooms = Room.all
    @instructors = Instructor.all
  end

  def new
    @pilates_class = PilatesClass.new
    @rooms = Room.all
    @instructors = Instructor.all
    # Valores por defecto
    @pilates_class.start_time = Time.current.beginning_of_hour + 1.hour
    @pilates_class.end_time = @pilates_class.start_time + 1.hour
    @pilates_class.max_capacity = 10
    @pilates_class.level = :basic
    @pilates_class.class_type = :grupal
  end

  def create
    @pilates_class = PilatesClass.new(pilates_class_params)
    @rooms = Room.all
    @instructors = Instructor.all

    if @pilates_class.save
      redirect_to management_classes_path, notice: "Clase creada exitosamente"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @rooms = Room.all
    @instructors = Instructor.all
  end

  def update
    if @pilates_class.update(pilates_class_params)
      redirect_to management_classes_path, notice: "Clase actualizada exitosamente"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @pilates_class.destroy
    redirect_to management_classes_path, notice: "Clase eliminada exitosamente"
  end

  def calendar
    @date = params[:date] ? Date.parse(params[:date]) : Date.current
    @week_start = @date.beginning_of_week(:monday)
    @week_end = @week_start + 6.days

    @classes = PilatesClass.where("DATE(start_time) >= ? AND DATE(start_time) <= ?", @week_start, @week_end)
                           .order(start_time: :asc)
    @classes_by_day = @classes.group_by { |c| c.start_time.to_date }
  end

  private

  def set_pilates_class
    @pilates_class = PilatesClass.find(params[:id])
  end

  def pilates_class_params
    params.require(:pilates_class).permit(:name, :level, :class_type, :room_id, :instructor_id, :start_time, :end_time, :max_capacity)
  end
end
