require 'sinatra/base'
require 'sinatra/cross_origin'
require 'sinatra/contrib'
require 'sinatra/json'
require 'sinatra/namespace'
require 'json'
require 'sinatra/flash'
require 'data_mapper'
require 'dm-migrations'
require 'bcrypt'
# require 'pry'
require './lib/product.rb'
require './lib/brand.rb'
require './lib/category.rb'
require 'dotenv'

class Love < Sinatra::Base
  register Sinatra::Namespace
  set :views, proc { File.join(root, '..', 'views') }
  enable :sessions
  register Sinatra::CrossOrigin
  register Sinatra::Flash
  set :session_secret, '123321123'
  use Rack::Session::Pool
  env = ENV['RACK_ENV'] || "development"
  Dotenv.load

  DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/love_#{env}")
  DataMapper.finalize
  DataMapper.auto_upgrade!
  #DataMapper.auto_migrate!
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
      brand = Brand.get(params[:brand])
      category = Category.get(params[:category])
      Product.first_or_create(brand: brand, product_name: params[:product_name], category: category, barcode: params[:barcode], sugar_content_gram: params[:sugar_content_gram])
      redirect '/admin/product_listing'
    rescue
      redirect 'admin/fill_out'
    end
  end

  get '/admin/add_product' do
    protected!
    erb :'admin/add_product', layout: :'admin/admin_layout'
  end

  post '/admin/add_product' do
    protected!
    begin
      barcode = params[:barcode]
      Product.import_product(params[:barcode])
      redirect '/admin/product_listing'
    rescue
      redirect 'admin/add_product'
    end
  end

  get '/admin/product_listing' do
    #protected!
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

  # API-related code below (example from here http://www.sinatrarb.com/contrib/json.html)

  namespace '/api/v1' do
    # This route is for testing in browser. Delete it whenever want.
    get '/' do
      json :Hey! => 'Joe!'
    end

    get '/product_listing' do
      cross_origin
      @product = Product.all
      @product.to_json
    end

    get '/product_listing/:barcode' do
      cross_origin
      @product = Product.first(barcode: params[:barcode])
      @product.to_json
      # binding.pry
    end
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
