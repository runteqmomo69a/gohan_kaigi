class ShopLogsController < ApplicationController
  def index
    @shops = current_user.shops
                         .includes(:event)
                         .order(created_at: :desc)
  end
end
