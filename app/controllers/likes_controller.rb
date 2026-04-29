# frozen_string_literal: true

class LikesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event
  before_action :set_shop
  before_action :ensure_event_participant

  def create
    current_user.likes.create!(shop: @shop)
    @shop.reload
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          helpers.dom_id(@shop, :reaction),
          partial: "events/shop_reaction",
          locals: {
            event: @event,
            shop: @shop,
            current_sort: current_sort,
            toast_message: t("flash.likes.create.notice")
          }
        )
      end
      format.html do
        redirect_to event_path(@event, sort: current_sort), notice: t("flash.likes.create.notice")
      end
    end
  end

  def destroy
    current_user.likes.find_by!(shop: @shop).destroy
    @shop.reload
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          helpers.dom_id(@shop, :reaction),
          partial: "events/shop_reaction",
          locals: {
            event: @event,
            shop: @shop,
            current_sort: current_sort,
            toast_message: t("flash.likes.destroy.notice")
          }
        )
      end
      format.html do
        redirect_to event_path(@event, sort: current_sort), notice: t("flash.likes.destroy.notice")
      end
    end
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

    redirect_to event_path(@event, sort: current_sort), alert: t("flash.likes.participant_only.alert")
  end

  def current_sort
    params[:sort].presence
  end
end
