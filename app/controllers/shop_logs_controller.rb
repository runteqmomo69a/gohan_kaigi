class ShopLogsController < ApplicationController
  def index
    @shops = current_user.shops
                         .includes(:event)
                         .order(created_at: :desc)
  end

  def edit
    @shop = current_user.shops.find(params[:id])
  end

  def update
    @shop = current_user.shops.find(params[:id])

    if @shop.update(shop_params)
      redirect_to shop_logs_path, notice: "カテゴリを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def shop_params
    params.require(:shop).permit(:log_category)
  end
end
