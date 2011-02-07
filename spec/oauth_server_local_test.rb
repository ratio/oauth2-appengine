require 'rspec'
require 'mechanize'
require 'json'

def server_url(path)
  "http://localhost:#{ENV['PORT']||8080}#{path}"
end

CLIENT_ID = '54d1bbc5b2264e4704661c3450d821d6e1100e8b'
CLIENT_SECRET = '4c108aaa9745164a4779345e5d47c1719e388322'
CLIENT_REDIRECT = 'http://localhost:3333/callback'
OWNER_USERNAME = 'ac123'
OWNER_PASSWORD = '123'

describe 'OAuth Access Token Endpoint' do
  it "lets client obtain access token with end-user credentials" do
    page = Mechanize.new.post(server_url("/oauth/token"), {
      "grant_type"  => "password",
      "client_id"   => CLIENT_ID,
      "client_secret" => CLIENT_SECRET,
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
      "client_secret" => CLIENT_SECRET,
      "username" => OWNER_USERNAME,
      "password" => OWNER_PASSWORD,
    })
    response = JSON.parse(page.body)
    refresh_token = response['refresh_token']
    page = Mechanize.new.post(server_url("/oauth/token"), {
      "grant_type"  => "refresh_token",
      "client_id"   => CLIENT_ID,
      "client_secret" => CLIENT_SECRET,
      "refresh_token" => refresh_token,
    })
    response = JSON.parse(page.body)
    response.keys.should include("access_token")
  end
  
  it "lets client obtain access token with only client credentials" do
    page = Mechanize.new.post(server_url("/oauth/token"), {
      "grant_type"  => "client_credentials",
      "client_id"   => CLIENT_ID,
      "client_secret" => CLIENT_SECRET,
    })
    response = JSON.parse(page.body)
    response.keys.should include("access_token")
  end
end

describe 'OAuth Authorization Endpoint' do
  it "lets a client get end-user authorization" do
    page = Mechanize.new.get(server_url("/oauth/authorize"), {
      "response_type" => "code",
      "client_id"     => CLIENT_ID,
      "redirect_uri" => CLIENT_REDIRECT,
    })
    # do local app engine sdk auth
    
    
    page.body.should include(CLIENT_ID)
  end
end
