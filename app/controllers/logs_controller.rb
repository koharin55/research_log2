# frozen_string_literal: true

class LogsController < ApplicationController
  before_action :set_log, only: %i[edit update destroy toggle_pin increment_copy_count]
  before_action :set_form_data, only: %i[new create edit update]

  def index
    @categories = current_user.categories.order(:name)

    query = LogQuery.new(current_user, filter_params)

    @keyword              = filter_params[:q]
    @keyword_mode         = query.keyword_mode
    @selected_category_id = filter_params[:category_id]
    @selected_tag_ids     = Array(filter_params[:tag_ids]).reject(&:blank?)
    @sort                 = filter_params[:sort].presence || 'updated'

    @pinned_logs  = query.pinned_logs
    @other_logs   = query.other_logs(filter_params[:page])
    @pinned_count = @pinned_logs.size
    @other_count  = @other_logs.total_count
    @total_count  = @pinned_count + @other_count

    @tag_suggestions = query.tag_suggestions

    @selected_log =
      if filter_params[:selected_id].present?
        query.call.find_by(id: filter_params[:selected_id])
      else
        @pinned_logs.first || @other_logs.first
      end
  end

  # GET /logs/new
  def new
    @log = current_user.logs.new
  end

  # POST /logs
  def create
    @log = current_user.logs.new(log_params)

    if @log.save
      attach_images(@log)
      assign_tags(@log)
      redirect_to logs_path(selected_id: @log.id), notice: 'ログを作成しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /logs/:id/edit
  def edit; end

  # PATCH/PUT /logs/:id
  def update
    # ▼ ここから削除処理（必ず where(id: ids) を噛ませる）
    if params[:log] && params[:log][:remove_image_ids].present?
      ids = params[:log][:remove_image_ids].map(&:to_i)
      @log.images.where(id: ids).each(&:purge_later)
    end

    if @log.update(log_params)
      attach_images(@log) # ← 更新時もここで追加
      assign_tags(@log)
      redirect_to logs_path(selected_id: @log.id), notice: 'ログを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /logs/:id
  def destroy
    @log.destroy
    redirect_to logs_path, notice: 'ログを削除しました。'
  end

  # PATCH /logs/:id/toggle_pin
  def toggle_pin
    @log.update(pinned: !@log.pinned)
    redirect_to logs_path(selected_id: @log.id), notice: (@log.pinned? ? 'ピン留めしました。' : 'ピン留めを外しました。')
  end

  # POST /logs/:id/increment_copy_count
  # CopyボタンのJSから叩く想定（レスポンスはステータスのみ）
  def increment_copy_count
    @log.increment!(:copy_count)
    head :ok
  end

  private

  def set_log
    @log = current_user.logs.find(params[:id])
  end

  def set_form_data
    @categories    = current_user.categories.order(:name)
    @existing_tags = Tag.used_by_user(current_user)
  end

  def filter_params
    @filter_params ||= params.permit(:q, :keyword_mode, :category_id, :sort, :page, :selected_id, tag_ids: [])
  end

  # ストロングパラメーター
  def log_params
    params.require(:log).permit(
      :title,
      :body,
      :code,
      :memo,
      :category_id
    )
  end

  def attach_images(log)
    return unless params[:log] && params[:log][:images].present?

    params[:log][:images].each do |image|
      next if image.blank?          # ["", #<UploadedFile ...>] の空文字をスキップ

      log.images.attach(image)      # ← ここが「追加」になる
    end
  end

  # タグの紐付け（フォームから tag_names を "Ruby, Rails, scope" みたいな形式で受け取る想定）
  def assign_tags(log)
    return unless params[:tag_names].present?

    names = params[:tag_names]
            .split(',')
            .map(&:strip)
            .reject(&:blank?)

    tags = names.map { |name| Tag.find_or_create_by(name: name) }
    log.tags = tags
  end
end
