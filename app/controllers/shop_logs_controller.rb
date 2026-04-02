class ShopLogsController < ApplicationController
  def index
    @shops = current_user.shops.includes(:event)

    # カテゴリ絞り込み
    if params[:category].present?
      @shops = @shops.where(log_category: params[:category])
    end

    # 並び替え
    @shops =
      case params[:sort]
      when "old"
        @shops.order(created_at: :asc)
      else
        @shops.order(created_at: :desc)
      end

    # カテゴリ一覧（セレクト用）
    @categories = current_user.shops
                              .where.not(log_category: [nil, ""])
                              .distinct
                              .pluck(:log_category)
  end

  def edit
    @shop = current_user.shops.find(params[:id])
  end

  def update
    @shop = current_user.shops.find(params[:id])

    if @shop.update(shop_params)
      redirect_to shop_logs_path, notice: "お店ログを更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def shop_params
    params.require(:shop).permit(:log_category, :log_note)
  end
end