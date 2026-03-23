class EventPreferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :ensure_event_participant

  def create
    @event_preference = @event.event_preferences.find_or_initialize_by(user: current_user)
    
    if @event_preference.update(event_preference_params)
      redirect_to event_path(@event), notice: "希望の条件を保存しました"
    else
      redirect_to event_path(@event), alert: "希望の条件の保存に失敗しました"
    end
  end

  def destroy
    @event_preference = @event.event_preferences.find_by(user: current_user)
    @event_preference.destroy if @event_preference
    redirect_to event_path(@event), notice: "希望条件を削除しました"
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def ensure_event_participant
    unless @event.participants.exists?(current_user.id)
      redirect_to event_path(@event), alert: "イベント参加者のみ希望条件を入力できます"
    end
  end

  def event_preference_params
    params.require(:event_preference).permit(:dislike_foods, :budget, :content)
  end
end
