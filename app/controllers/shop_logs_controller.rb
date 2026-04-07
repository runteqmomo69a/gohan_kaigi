# frozen_string_literal: true

class ShopLogsController < ApplicationController
  def index
    @shops = current_user.shops.includes(:event)

    # 検索
    @shops = @shops.where("name LIKE ?", "%#{params[:q]}%") if params[:q].present?

    # カテゴリ絞り込み
    @shops = @shops.where(log_category: params[:category]) if params[:category].present?

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
                              .where.not(log_category: [ nil, "" ])
                              .distinct
                              .pluck(:log_category)
  end

  # オートコンプリート
  def autocomplete
    shops = current_user.shops

    shops = if params[:q].present?
              shops.where("name LIKE ?", "%#{params[:q]}%").limit(5)
    else
              []
    end

    render json: shops.pluck(:name)
  end

  def edit
    @shop = current_user.shops.find(params[:id])
  end

  def update
    @shop = current_user.shops.find(params[:id])

    if @shop.update(shop_params)
      redirect_to shop_logs_path, notice: t("flash.shop_logs.update.notice")
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def shop_params
    params.require(:shop).permit(:log_category, :log_note)
  end
end
