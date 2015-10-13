require 'net/http'
require "json"

class Product

  include DataMapper::Resource

  property :id, Serial
  property :product_name, String
  property :barcode, String
  property :sugar_content_gram, Float
  property :ranking, Integer
  property :image_url, Text

  belongs_to :brand
  belongs_to :category

  validates_presence_of :product_name, message: "Please fill in a name."
  validates_presence_of :barcode, message: "Please fill in barcode."
  validates_uniqueness_of :barcode, message: "Barcode already exists."
  #validates_presence_of :sugar_content_gram, message: "Please fill in sugar content."

  def self.rank(product)
    result = all(:sugar_content_gram.lt => product.sugar_content_gram).count+1
    product.update!(ranking: result)
  end

  def self.update_ranking
    Product.all.each do |product|
      result = all(:sugar_content_gram.lt => product.sugar_content_gram).count+1
      product.update!(ranking: result)
    end
  end

  def self.dabas_barcode(barcode)
    dabasbar = "0" + barcode
  end

  def self.find_product(barcode)
    product = Product.first(barcode: barcode)
  end

  def self.import_product(barcode)
    request_uri = 'http://api.dabas.com/DABASService/V1/article/gtin/'
    request_query = barcode
    request_end_uri = "/json?apikey=#{ENV['DABAS_API']}"
    uri = URI("#{request_uri}#{request_query}#{request_end_uri}")
    @response = JSON.parse(Net::HTTP.get(uri))
    brand = Brand.first_or_create(name: @response["VarumarkeTillverkare"])
    cat = Category.first_or_create(name: @response["Produktkod".to_s])
    Product.create(brand: brand, product_name: @response["Artikelbenamning"], category: cat, barcode: @response["GTIN"], sugar_content_gram: @response["Naringsinfo"][0]["Naringsvarden"][5]["Mangd"], image_url: @response["Bilder"][0]["Lank"])
    Product.update_ranking
  end

  def self.api_product_to_json(barcode)
    @product = find_product(barcode)
    product_hash = @product.attributes
    brand = @product.brand.name
    category = @product.category.name
    brandarr = brand.downcase.strip.split('/')
    product_hash.merge!(brand_name: "#{brandarr[0].downcase.capitalize}", category_name: category)
    product_hash.to_json
  end

  #Rankning can be seen as how many Products have suger_content_gram that is lower than current record + 1

end
