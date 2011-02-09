require 'rspec'
require 'mechanize'
require 'json'

def server_url(path)
  "http://localhost:#{ENV['PORT']||8080}#{path}"
end

CLIENT_ID = 'af5859b5bf7b35f172a0eab126d072a5227f4465'
CLIENT_SECRET = '13a152404029e4fa1ee8a680cddac8ee97698293'
CLIENT_REDIRECT = 'http://localhost:3333/callback'
OWNER_USERNAME = 'ac123'
OWNER_PASSWORD = '123'

describe 'OAuth Access Token Endpoint' do
  it "lets client obtain access token with end-user credentials" do
    page = Mechanize.new.post(server_url("/oauth/token"), {
      "grant_type"  => "password",
      "client_id"   => CLIENT_ID,
      # "client_secret" => CLIENT_SECRET,
      "username" => OWNER_USERNAME,
      "password" => OWNER_PASSWORD,
    })
    response = JSON.parse(page.body)
    response.keys.should include("access_token")
  end

  it "lets client obtain access token with a refresh token" do
    page = Mechanize.new.post(server_url("/oauth/token"), {
      "grant_type"  => "password",
      "client_id"   => CLIENT_ID,
      # "client_secret" => CLIENT_SECRET,
      "username" => OWNER_USERNAME,
      "password" => OWNER_PASSWORD,
    })
    response = JSON.parse(page.body)
    response.keys.should include("refresh_token")
    refresh_token = response['refresh_token']
    page = Mechanize.new.post(server_url("/oauth/token"), {
      "grant_type"  => "refresh_token",
      "client_id"   => CLIENT_ID,
      # "client_secret" => CLIENT_SECRET,
      "refresh_token" => refresh_token,
    })
    response = JSON.parse(page.body)
    response.keys.should include("access_token")
  end
  #
  # TODO: not yet implement in OAuth::Lite2
  # it "lets client obtain access token with only client credentials" do
  #   page = Mechanize.new.post(server_url("/oauth/token"), {
  #     "grant_type"  => "client_credentials",
  #     "client_id"   => CLIENT_ID,
  #     "client_secret" => CLIENT_SECRET,
  #   })
  #   response = JSON.parse(page.body)
  #   response.keys.should include("access_token")
  # end

  it "lets client obtain access token with client authorization code" do
    page = Mechanize.new.post(server_url("/oauth/token"), {
      "grant_type"  => "authorization_code",
      "client_id"   => CLIENT_ID,
      "client_secret" => CLIENT_SECRET,
      "code" => "code_bar",
      "redirect_uri" => CLIENT_REDIRECT,
    })
    response = JSON.parse(page.body)
    response.keys.should include("access_token")
  end

end

describe 'OAuth Authorization Endpoint' do
  it "lets a client get end-user authorization" do
    a = Mechanize.new { |agent| agent.follow_meta_refresh = true }
    page = a.post(server_url("/oauth/authorize"), {
      "response_type" => "code",
      "client_id"     => CLIENT_ID,
      "redirect_uri" => CLIENT_REDIRECT,
    })
    page.uri.request_uri.should include("code=code_bar")
  end
end
