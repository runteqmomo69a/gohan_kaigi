# frozen_string_literal: true

class EventPreferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :ensure_event_participant

  def create
    @event_preference = @event.event_preferences.find_or_initialize_by(user: current_user)

    if @event_preference.update(event_preference_params)
      redirect_to event_path(@event), notice: t("flash.event_preferences.create.notice")
    else
      redirect_to event_path(@event), alert: t("flash.event_preferences.create_failed.alert")
    end
  end

  def destroy
    @event_preference = @event.event_preferences.find_by(user: current_user)
    @event_preference&.destroy
    redirect_to event_path(@event), notice: t("flash.event_preferences.destroy.notice")
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def ensure_event_participant
    return if @event.participants.exists?(current_user.id)

    redirect_to event_path(@event), alert: t("flash.event_preferences.participant_only.alert")
  end

  def event_preference_params
    params.require(:event_preference).permit(:dislike_foods, :budget, :content)
  end
end
