# frozen_string_literal: true

class EventParticipantsController < ApplicationController
  before_action :authenticate_user!

  def create
    @event = Event.find(params[:event_id])
    @event_participant = @event.event_participants.new(user: current_user)

    if @event_participant.save
      redirect_to event_path(@event), notice: t("flash.event_participants.create.notice")
    else
      redirect_to event_path(@event), alert: t("flash.event_participants.create_failed.alert")
    end
  end
end
