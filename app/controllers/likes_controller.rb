# frozen_string_literal: true

class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :set_shop
  before_action :ensure_event_participant

  def create
    current_user.likes.create!(shop: @shop)
    redirect_to event_path(@event), notice: "いいねしました"
  end

  def destroy
    current_user.likes.find_by!(shop: @shop).destroy
    redirect_to event_path(@event), notice: "いいねを解除しました"
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_shop
    @shop = @event.shops.find(params[:shop_id])
  end

  def ensure_event_participant
    return if @event.participants.exists?(current_user.id)

    redirect_to event_path(@event), alert: "イベント参加者のみいいねできます"
  end
end
