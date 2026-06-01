class LogsController < ApplicationController
  before_action :set_log, only: %i[edit update destroy toggle_pin increment_copy_count]

  # GET /logs
  # メイン画面：検索・フィルタ・ピン留め・詳細表示
  def index
    @categories = current_user.categories.order(:name)

    # 検索フォームの状態保持用インスタンス変数
    @keyword      = params[:q]
    @keyword_mode = params[:keyword_mode].presence_in(%w[and or]) || "and"
    @selected_category_id = params[:category_id]
    @selected_tag_ids     = Array(params[:tag_ids]).reject(&:blank?)
    @sort                 = params[:sort].presence || "updated"

    base = current_user.logs
                       .includes(:category, :tags)

    base = apply_filters(base)

    @pinned_logs = base.where(pinned: true)
    @other_logs  = base.where(pinned: false)
    @pinned_count = @pinned_logs.to_a.size
    @other_count  = @other_logs.to_a.size
    @total_count  = @pinned_count + @other_count

    # フィルタ後の結果に出現するタグのみを候補に表示
    @tag_suggestions = Tag.joins(:logs)
                      .merge(base.reorder(nil)) # drop ORDER BY from base to avoid DISTINCT clash
                      .distinct
                      .order(:name)

    @selected_log =
      if params[:selected_id].present?
        base.find_by(id: params[:selected_id])
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
      redirect_to logs_path(selected_id: @log.id), notice: "ログを作成しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /logs/:id/edit
  def edit
  end

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
      redirect_to logs_path(selected_id: @log.id), notice: "ログを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /logs/:id
  def destroy
    @log.destroy
    redirect_to logs_path, notice: "ログを削除しました。"
  end

  # PATCH /logs/:id/toggle_pin
  def toggle_pin
    @log.update(pinned: !@log.pinned)
    redirect_to logs_path(selected_id: @log.id), notice: (@log.pinned? ? "ピン留めしました。" : "ピン留めを外しました。")
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

  # 検索・フィルタ・ソートの適用
  def apply_filters(scope)
    # キーワード検索（タイトル / メモ / コード）
    if params[:q].present?
      scope = scope.keyword_search(params[:q], mode: @keyword_mode)
    end

    # カテゴリフィルタ
    if params[:category_id].present?
      scope = scope.by_category(params[:category_id])
    end

    # タグで絞り込み
    if params[:tag_ids].present?
      # 複数タグ指定（すべて含むログのみ）
      scope = scope.with_any_tags(params[:tag_ids])
    elsif params[:tag].present?
      # 旧仕様：単一タグ名での絞り込み（後方互換）
      scope = scope.joins(:tags).where(tags: { name: params[:tag] }).distinct
    end

    # ソート
    case params[:sort]
    when "used"
      scope.order(copy_count: :desc)
    when "title_asc"
      scope.order(title: :asc)
    else
      scope.order(updated_at: :desc)
    end
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
              .split(",")
              .map(&:strip)
              .reject(&:blank?)

    tags = names.map { |name| Tag.find_or_create_by(name: name) }
    log.tags = tags
  end
end
