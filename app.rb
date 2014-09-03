require 'sinatra'
require 'sinatra/reloader'
require 'oauth'
require 'json'

enable :sessions

API_KEY = ''
API_SECRET = ''

get '/' do
  erb :index
end

get '/request-oauth-token' do
  request_token = @oauth.get_request_token( :oauth_callback => 'http://127.0.0.1:4567/callback')
  session[:token] = request_token.token
  session[:secret] = request_token.secret
  redirect request_token.authorize_url
end

get '/callback' do
  request_token = OAuth::RequestToken.new( @oauth, session[:token], session[:secret] ) 
  access_token = request_token.get_access_token( :oauth_verifier => params[:oauth_verifier])
  session[:access_token] = access_token
  redirect '/tweets'
end

get '/tweets' do
  @tweets = JSON.parse( @oauth.request(:get, '/1.1/statuses/home_timeline.json', session[:access_token], { :scheme => :query_string }).body )
  erb :tweets
end

before do
  @oauth = OAuth::Consumer.new( API_KEY, API_SECRET, { site: "https://api.twitter.com"})
end

