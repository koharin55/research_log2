# frozen_string_literal: true

# ログの検索・フィルタ・ソートを一元管理するクエリオブジェクト
class LogQuery
  PER_PAGE = 20

  def initialize(user, params)
    @user   = user
    @params = params
  end

  def call
    @call ||= begin
      scope = @user.logs.with_attached_images.includes(:category, :tags)
      scope = apply_keyword(scope)
      scope = apply_category(scope)
      scope = apply_tags(scope)
      apply_sort(scope)
    end
  end

  def pinned_logs
    call.where(pinned: true).load
  end

  def other_logs(page)
    call.where(pinned: false).page(page).per(PER_PAGE)
  end

  def tag_suggestions
    Tag.joins(:logs)
       .merge(call.except(:includes).reorder(nil))
       .distinct
       .order(:name)
  end

  def keyword_mode
    @params[:keyword_mode].presence_in(%w[and or]) || 'and'
  end

  private

  def apply_keyword(scope)
    return scope unless @params[:q].present?

    scope.keyword_search(@params[:q], mode: keyword_mode)
  end

  def apply_category(scope)
    return scope unless @params[:category_id].present?

    scope.by_category(@params[:category_id])
  end

  def apply_tags(scope)
    if @params[:tag_ids].present?
      scope.with_any_tags(@params[:tag_ids])
    elsif @params[:tag].present?
      scope.joins(:tags).where(tags: { name: @params[:tag] }).distinct
    else
      scope
    end
  end

  def apply_sort(scope)
    case @params[:sort]
    when 'used'      then scope.order(copy_count: :desc)
    when 'title_asc' then scope.order(title: :asc)
    else                  scope.order(updated_at: :desc)
    end
  end
end
