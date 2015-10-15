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
require 'pry'
require './lib/product.rb'
require './lib/brand.rb'
require './lib/category.rb'
require './lib/users.rb'
require 'dotenv'
require 'tilt/erb'

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



  get '/join' do
    erb :join
  end

  post '/join' do
    if (params[:name] == '') || (params[:email] == '') || (params[:user_name] == '') || (params[:password] == '') || (params[:password_confirm] == '')
      flash[:warning] = "Some data is missing, please try again."
      redirect '/join'
    else
      new_user = User.new
      new_user.name = params[:name]
      new_user.user_name = params[:user_name]
      new_user.email = params[:email]
      new_user.password = params[:password]
      new_user.password_confirm = params[:password_confirm]
      new_user.save
      redirect '/'
    end
  end

  get '/sign_in' do
    erb :sign_in
  end

  post '/sign_in' do
    if ((params[:email] == '') || (params[:password] == ''))
      flash[:warning] = "You must have missed a field.  Please try again."
      redirect '/sign_in'

    else

      begin
        email = params[:email]
        password = params[:password]
        @user = User.authenticate(email, password)
        session[:user_id] = @user.id
        flash[:notice] = "Welcome #{@user.name}!"
        redirect '/'
      rescue
        flash[:warning] = "Some data is invalid.  Please try again."
        redirect "/sign_in"
      end
    end
  end

  # Testing the authentication. TODO: Delete this later.
  # Testing the authentication. Can delete this later (if want to refactor tests)
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
      brand = Brand.get(params[:brand])
      category = Category.get(params[:category])
      product.update(brand: brand, product_name: params[:product_name], category: category, barcode: params[:barcode], sugar_content_gram: params[:sugar_content_gram])
      redirect '/admin/product_listing'
    rescue
      redirect '/admin/update_product/:id'
    end
  end

  get '/sign_out' do
    session[:user_id] = nil
    flash[:notice] = "Thanks for visiting, hope to see you soon again!"
    redirect '/'
  end

  # API-related code below (example from here http://www.sinatrarb.com/contrib/json.html)

  namespace '/api/v1' do

    get '/product_listing' do
      cross_origin
      @product = Product.all
      @product.to_json
    end

    get '/product_listing/:barcode' do
      cross_origin
      barcode = Product.dabas_barcode(params[:barcode])
      if Product.find_product(barcode).nil?
        Product.import_product(barcode)
        Product.api_product_to_json(barcode)
      else
        Product.api_product_to_json(barcode)
      end
    end
  end

  get '/categories' do
    cross_origin
    @category = Category.all
    erb :'web/categories'
  end

  get '/category/:category_id' do
    cross_origin
    # TODO: Code goes here.
    erb :'web/category'
  end

  get '/product/:barcode' do
    cross_origin
    @product = Product.first(barcode: params[:barcode])
    erb :'web/product'
  end

  get '/search/:query' do
    cross_origin
    # binding.pry
    @product_by_barcode = Product.first(barcode: params[:query])
    @brand = Brand.first(name: params[:query])
    @category = Category.first(name: params[:query])
    @product = Product.first(product_name: params[:query])
    erb :'web/search'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0

end

