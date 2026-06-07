# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe LogQuery, type: :service do
  let(:user)     { create(:user) }
  let(:category) { create(:category, user: user) }

  def query(params = {})
    described_class.new(user, ActionController::Parameters.new(params)).call
  end

  before { create_list(:log, 3, user: user, category: category) }

  describe '#call' do
    it 'ユーザーのログのみを返す' do
      other_user = create(:user)
      create(:log, user: other_user, category: create(:category, user: other_user))
      expect(query.map(&:user_id).uniq).to eq([user.id])
    end

    it 'デフォルトは更新日降順' do
      results = query
      expect(results.to_a).to eq(results.reorder(updated_at: :desc).to_a)
    end

    context 'キーワード検索' do
      it 'タイトルに一致するログを返す' do
        target = create(:log, user: user, category: category, title: 'Ruby on Rails ガイド')
        expect(query(q: 'Rails')).to include(target)
      end
    end

    context 'カテゴリフィルタ' do
      it '指定カテゴリのログのみを返す' do
        other_category = create(:category, user: user)
        target = create(:log, user: user, category: other_category)
        results = query(category_id: other_category.id)
        expect(results).to include(target)
        expect(results.map(&:category_id).uniq).to eq([other_category.id])
      end
    end

    context 'ソート' do
      it 'sort=used でコピー回数降順' do
        results = query(sort: 'used')
        expect(results.to_a).to eq(results.reorder(copy_count: :desc).to_a)
      end

      it 'sort=title_asc でタイトル昇順' do
        results = query(sort: 'title_asc')
        expect(results.to_a).to eq(results.reorder(title: :asc).to_a)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
