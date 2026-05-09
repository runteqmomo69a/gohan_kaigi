# frozen_string_literal: true

module EventShowResources
  extend ActiveSupport::Concern

  private

  def load_event_show_resources
    @participating = user_signed_in? && @event.event_participants.exists?(user_id: current_user.id)
    @participants = @event.participants
    @current_sort = current_event_show_sort
    @shops = event_show_shops
    @top_shops = @event.shops.order(likes_count: :desc, created_at: :asc).limit(self.class::TOP_SHOPS_LIMIT)
    @event_preferences = @event.event_preferences.order(updated_at: :desc)
  end

  def current_event_show_sort
    params[:sort] == "likes_count" ? "likes_count" : "created_at"
  end

  def event_show_shops
    case @current_sort
    when "likes_count"
      @event.shops.includes(:user, :likes).order(likes_count: :desc, created_at: :asc)
    else
      @event.shops.includes(:user, :likes).order(created_at: :asc)
    end
  end
end
