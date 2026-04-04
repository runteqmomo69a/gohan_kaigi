# frozen_string_literal: true

class ShopsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :ensure_event_participant
  before_action :set_shop, only: %i[edit update destroy]
  before_action :ensure_shop_owner, only: %i[edit update destroy]

  def new
    @shop = @event.shops.new
  end

  def edit; end

  def create
    @shop = @event.shops.new(shop_params)
    @shop.user = current_user

    @shop.place_id = @shop.fetch_place_id(@event.place)

    if @shop.save
      redirect_to event_path(@event), notice: "お店候補を登録しました"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    # まずフォームの内容を @shop に反映する（まだ保存はしない）
    @shop.assign_attributes(shop_params)

    # 名前が変更された場合のみ place_id を再取得
    if @shop.will_save_change_to_name?
      new_place_id = @shop.fetch_place_id(@event.place)
      @shop.place_id = new_place_id if new_place_id.present?
    end

    if @shop.save
      redirect_to event_path(@event), notice: "お店候補を更新しました"
    else
      render :edit, status: :unprocessable_content
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
    return if @event.participants.exists?(current_user.id)

    redirect_to event_path(@event), alert: "イベント参加者のみお店候補を操作できます"
  end

  def set_shop
    @shop = @event.shops.find(params[:id])
  end

  def ensure_shop_owner
    return if @shop.user == current_user

    redirect_to event_path(@event), alert: "お店候補の編集・削除は登録者のみ可能です"
  end

  def shop_params
    params.require(:shop).permit(:name, :url, :address, :memo)
  end
end
