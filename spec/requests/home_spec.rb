# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Homes', type: :request do
  before do
    ENV['BASIC_AUTH_USER']     = 'test_user'
    ENV['BASIC_AUTH_PASSWORD'] = 'test_pass'
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

  describe 'GET /' do
    it 'returns http success' do
      get '/', headers: basic_auth_headers
      expect(response).to have_http_status(:success)
    end
  end
end
