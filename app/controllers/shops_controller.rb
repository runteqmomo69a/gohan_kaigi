class ShopsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :ensure_event_participant
  before_action :set_shop, only: %i[edit update destroy]

  def new
    @shop = @event.shops.new
  end

  def create
    @shop = @event.shops.new(shop_params)
    @shop.user = current_user

    if @shop.save
      redirect_to event_path(@event), notice: "お店候補を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @shop.update(shop_params)
      redirect_to event_path(@event), notice: "お店候補を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @shop.destroy
    redirect_to event_path(@event), notice: "お店候補を削除しました"
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def ensure_event_participant
    unless @event.participants.exists?(current_user.id)
      redirect_to event_path(@event), alert: "イベント参加者のみお店候補を操作できます"
    end
  end

  def set_shop
    @shop = @event.shops.find(params[:id])
  end

  def shop_params
    params.require(:shop).permit(:name, :url, :address, :memo)
  end
end