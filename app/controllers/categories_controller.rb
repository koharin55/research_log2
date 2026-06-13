class CategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_category, only: %i[edit update destroy]

  def index
    @categories = current_user.categories.order(:position, :name)
    @category   = current_user.categories.new
  end

  def create
    @category = current_user.categories.new(category_params)
    @category.save ? respond_to_category_created : respond_to_category_failed
  end

  def edit; end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: "カテゴリを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path, notice: "\"#{@category.name}\"カテゴリを削除しました。（関連ログのカテゴリは未設定になります）"
  end

  private

  def set_category
    @category = current_user.categories.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :color, :icon, :position)
  end

  def respond_to_category_created
    respond_to do |format|
      format.json { render json: { id: @category.id, name: @category.name }, status: :created }
      format.html { redirect_to categories_path, notice: "カテゴリを作成しました。" }
    end
  end

  def respond_to_category_failed
    respond_to do |format|
      format.json { render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity }
      format.html do
        @categories = current_user.categories.order(:position, :name)
        render :index, status: :unprocessable_entity
      end
    end
  end
end
