# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :authenticate_user!, except: %i[join]
  before_action :set_event, only: %i[show edit update destroy]
  before_action :ensure_event_owner!, only: %i[edit update destroy]

  def index
    # 選択中のタブに応じて表示するイベント一覧を切り替える
    @current_tab = params[:tab] == "joined" ? "joined" : "owned"
    @events =
      case @current_tab
      when "joined"
        current_user.participating_events.where.not(user_id: current_user.id).order(created_at: :desc)
      else
        current_user.events.order(created_at: :desc)
      end
  end

  def show
    @participating = user_signed_in? && @event.event_participants.exists?(user_id: current_user.id)
    @participants = @event.participants
    # 並び替え用
    @shops =
      case params[:sort]
      when "likes_count"
        @event.shops.includes(:user, :likes).order(likes_count: :desc, created_at: :asc)
      else
        @event.shops.includes(:user, :likes).order(created_at: :asc)
      end
    # ランキング用
    @top_shops = @event.shops.order(likes_count: :desc, created_at: :asc).limit(3)

    # 希望条件フォーム用
    @event_preference =
      if user_signed_in?
        @event.event_preferences.find_or_initialize_by(user: current_user)
      else
        EventPreference.new
      end

    # 希望条件一覧用
    @event_preferences = @event.event_preferences.order(updated_at: :desc)
  end

  def join
    @event = Event.find_by!(unique_url: params[:unique_url])

    unless @event
      redirect_to root_path, alert: t("flash.events.not_found.alert")
      return
    end

    unless user_signed_in?
      store_location_for(:user, join_event_path(@event.unique_url))
      redirect_to root_path, alert: t("flash.events.join_requires_auth.alert")
      return
    end

    redirect_to event_path(@event)
  end

  def new
    @event = Event.new
  end

  def edit; end

  def create
    @event = current_user.events.new(event_params)

    if @event.save
      @event.event_participants.create(user: current_user)
      redirect_to event_path(@event), notice: t("flash.events.create.notice")
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @event.update(event_params)
      redirect_to event_path(@event), notice: t("flash.events.update.notice")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @event.destroy!
    redirect_to events_path, notice: t("flash.events.destroy.notice")
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def event_params
    params.require(:event).permit(:title, :event_date, :event_time, :place, :note)
  end

  def ensure_event_owner!
    return if @event.user == current_user

    redirect_to event_path(@event), alert: t("flash.events.owner_only.alert"), status: :see_other
  end
end
