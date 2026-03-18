class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :set_shop

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
end
