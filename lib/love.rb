require 'sinatra/base'
require 'sinatra/flash'
require 'data_mapper'
require 'dm-migrations'
require 'bcrypt'
require 'byebug'
require './lib/product.rb'
require './lib/brand.rb'
require './lib/category.rb'

class Love < Sinatra::Base
  set :views, proc { File.join(root, '..', 'views') }
  enable :sessions
  register Sinatra::Flash
  set :session_secret, '123321123'
  use Rack::Session::Pool
  env = ENV['RACK_ENV'] || "development"

  DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/love_#{env}")
  DataMapper.finalize
  #DataMapper.auto_upgrade!
  DataMapper.auto_migrate!
  DataMapper::Model.raise_on_save_failure = true

  helpers do
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "You are not authorized\n"
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['love', 'shack']
    end
  end

  # Testing the authentication. TODO: Delete this later.
  get '/protected' do
    protected!
    "You're in, baby!"
  end

  get '/' do
    erb :index
  end

  get '/admin' do
    protected!
    redirect 'admin/fill_out'
  end

  get '/admin/fill_out' do
    protected!
    erb :'admin/fill_out', layout: :'admin/admin_layout'
  end

  post '/admin/fill_out' do
    protected!
    begin
      Product.create(brand: params[:brand], product_name: params[:product_name], category: params[:category], barcode: params[:barcode], sugar_content_gram: params[:sugar_content_gram])
      redirect '/admin/product_listing'
    rescue
      redirect 'admin/fill_out'
    end
  end

  get '/admin/product_listing' do
    protected!
    @product=Product.all
    erb :'admin/product_listing', layout: :'admin/admin_layout'
  end

  get '/admin/delete/:id' do
    protected!
    product = Product.get(params[:id])
    product.destroy!
    redirect '/admin/product_listing'
  end

  get '/admin/update_ranking' do
    protected!
    Product.update_ranking
    redirect '/admin/product_listing'
  end

  get '/admin/update_product/:id' do
    protected!
    @product = Product.get(params[:id])
    erb :'admin/update_product', layout: :'admin/admin_layout'
  end

  post '/admin/update_product/:id' do
    protected!
    product = Product.get(params[:id])
    begin
      product.update(brand: params[:brand], product_name: params[:product_name], category: params[:category], barcode: params[:barcode], sugar_content_gram: params[:sugar_content_gram])
      redirect '/admin/product_listing'
    rescue
      redirect '/admin/update_product/:id'
    end
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
