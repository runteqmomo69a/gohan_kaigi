class EventParticipantsController < ApplicationController
  before_action :authenticate_user!

  def create
    @event = Event.find(params[:event_id])
    @event_participant = @event.event_participants.new(user: current_user)

    if @event_participant.save
      redirect_to event_path(@event), notice: "イベントに参加しました"
    else
      redirect_to event_path(@event), alert: "イベントに参加できませんでした"
    end
  end
end
