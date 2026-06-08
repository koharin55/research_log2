# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'Logs', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:user)     { create(:user) }
  let(:category) { create(:category, user: user) }

  before do
    ENV['BASIC_AUTH_USER']     = 'test_user'
    ENV['BASIC_AUTH_PASSWORD'] = 'test_pass'
    sign_in user
  end

  after do
    ENV.delete('BASIC_AUTH_USER')
    ENV.delete('BASIC_AUTH_PASSWORD')
  end

  def basic_auth_headers
    credentials = Base64.strict_encode64(
      "#{ENV.fetch('BASIC_AUTH_USER', '')}:#{ENV.fetch('BASIC_AUTH_PASSWORD', '')}"
    )
    { 'HTTP_AUTHORIZATION' => "Basic #{credentials}" }
  end

  describe 'GET /logs' do
    context 'ログが存在するとき' do
      before { create_list(:log, 3, user: user, category: category) }

      it '200 を返す' do
        get logs_path, headers: basic_auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context 'ページネーション' do
      before { create_list(:log, LogQuery::PER_PAGE + 5, user: user, category: category) }

      it '1ページ目は200を返す' do
        get logs_path, headers: basic_auth_headers
        expect(response).to have_http_status(:ok)
      end

      it '2ページ目にアクセスできる' do
        get logs_path(page: 2), headers: basic_auth_headers
        expect(response).to have_http_status(:ok)
      end
    end

    context '他ユーザーのログが存在するとき' do
      it '他ユーザーのログは表示されない' do
        other_user = create(:user)
        create(:log, user: other_user, category: create(:category, user: other_user))
        get logs_path, headers: basic_auth_headers
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
