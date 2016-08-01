require 'sinatra/reloader'
require 'sinatra'
require 'pg'
require 'pry'

require_relative 'db_config'
require_relative 'models/cheerup'
require_relative 'models/user'
require_relative 'models/tag'
require_relative 'models/cheerup_tag'

enable :sessions

helpers do
  def logged_in?
    if User.find_by(id: session[:user_id])
      return true
    else
      return false #nil is falsey
    end
  end

  def current_user
    User.find(session[:user_id])
  end
#tag test for already existing tag, if not creates it and appends to @cheerup.tags
  def tag
  @tag = Tag.find_by(theme: params[:tag].downcase)
  if @tag
    @cheerup.tags << @tag
  else
    @tag = Tag.new
    @tag.theme = params[:tag].downcase
    @tag.save
    @cheerup.tags << @tag
  end
  end
end

get '/' do
  @cheerup = Cheerup.all
  erb :index
end

get '/session/new' do
  erb :register
end

post '/session' do
  # binding.pry
  user = User.find_by(email: params[:email])
  if user && user.authenticate(params[:password])
    session[:user_id] = user.id
    redirect to '/'
  elsif user
    redirect '/'
  elsif !user
    user = User.new
    user.name = params[:name]
    user.email = params[:email]
    user.password = params[:password]
    user.save
    session[:user_id] = user.id
    redirect '/'
  end
end

delete '/session' do
  session[:user_id] = nil
  redirect to '/'
end

get '/cheerup/new' do
  erb :new_cheerup
end

post '/cheerup' do
  if !logged_in?
    redirect to 'session/new'
  end

  @cheerup = Cheerup.new
  @cheerup.content = params[:content]
  @cheerup.image = params[:image]
  @cheerup.user_id = current_user.id
  @cheerup.save
  if params[:tag] != '' #if tag is an empty string, ignore it. else, tag method
    tag #
  # binding.pry
  end
  erb :display
end

put '/addtag/:cheerup_id' do
  params[:tag]
  @cheerup = Cheerup.find(params[:cheerup_id])
  # binding.pry
  tag #make sure this works over below code
  # @tag = Tag.find_by(theme: params[:tag])
  # if @tag
  #   @cheerup.tags << @tag
  # else
  #   @tag = Tag.new
  #   @tag.theme = params[:tag]
  #   @tag.save
  #   @cheerup.tags << @tag
  #   # binding.pry
  # end
  erb :display
end

get "/search/tag" do
  params[:tag]
  @tag = Tag.find_by(theme: params[:tag].downcase)
  if @tag
    erb :tag
  end
end
