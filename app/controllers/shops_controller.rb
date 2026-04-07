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
      redirect_to event_path(@event), notice: t("flash.shops.create.notice")
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
      redirect_to event_path(@event), notice: t("flash.shops.update.notice")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @shop.destroy
    redirect_to event_path(@event), notice: t("flash.shops.destroy.notice")
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def ensure_event_participant
    return if @event.participants.exists?(current_user.id)

    redirect_to event_path(@event), alert: t("flash.shops.participant_only.alert")
  end

  def set_shop
    @shop = @event.shops.find(params[:id])
  end

  def ensure_shop_owner
    return if @shop.user == current_user

    redirect_to event_path(@event), alert: t("flash.shops.owner_only.alert")
  end

  def shop_params
    params.require(:shop).permit(:name, :url, :address, :memo)
  end
end
