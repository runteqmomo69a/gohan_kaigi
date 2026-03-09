class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[show]
  before_action :set_current_user_event, only: %i[edit update destroy]

  def index
    @events = current_user.events.order(created_at: :desc)
  end

  def show
    @participating = user_signed_in? && @event.event_participants.exists?(user_id: current_user.id)
    @participants = @event.participants
  end

  def new
    @event = Event.new
  end

  def create
    @event = current_user.events.new(event_params)

    if @event.save
      @event.event_participants.create(user: current_user)
      redirect_to event_path(@event), notice: "イベントを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @event.update(event_params)
      redirect_to event_path(@event), notice: "イベントを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy!
    redirect_to events_path, notice: "イベントを削除しました"
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def set_current_user_event
    @event = current_user.events.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :event_date, :event_time, :place, :note)
  end
end