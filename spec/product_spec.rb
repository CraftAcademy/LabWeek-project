require 'product'
require 'product_helper_spec'

describe Product do

  it { is_expected.to have_property :id }
  it { is_expected.to have_property :product_name }
  it { is_expected.to have_property :barcode }
  it { is_expected.to have_property :sugar_content_gram }
  it { is_expected.to have_property :ranking }
  it { is_expected.to have_property :image_url }
  it { is_expected.to have_property :dabas_category }

  it { is_expected.to belong_to :brand }
  it { is_expected.to belong_to :category }

  it { is_expected.to validate_presence_of :product_name }
  it { is_expected.to validate_presence_of :barcode }
  it { is_expected.to validate_uniqueness_of :barcode }
  it { is_expected.to validate_presence_of :sugar_content_gram }

  it 'a product can be created' do
    create_products
    expect(Product.first.product_name).to eq "Lingongrova"
  end

  it 'have no ranking when created' do
    create_products
    expect(Product.first.ranking).to eq nil
  end

  it 'sets ranking within category' do
    create_products
    Product.update_ranking(Category.first(name: "Bröd"))
    expect(Product.first.ranking).to eq 1
  end

  it 'can find a product in the database' do
    create_products
    expect(Product.find_product("1212526767678").id).to eq 3
  end

  it 'can convert a 13 digit barcode to dabas 14 digit GTIN' do
    expect(Product.dabas_barcode("1212526767678")).to eq "01212526767678"
  end

  xit 'truncated a dabas id to a 4 digit main category' do
    response = double("response")
    allow(response).to receive(["Produktkod".to_s]).and_return("123456789")
    expect(Product.truncate_dabasid(response)).to eq "1234"
  end

  xit 'sets image url if available' do
    response = double("response")
    allow(response).to receive(["Bilder"][0]["Lank"]).and_return("http://www.test.com")
    expect(Product.image_url(response)).to eq "http://www.test.com"
  end

  xit 'sets image url to undefined if not available' do
    response = double("response")
    allow(response).to receive(["Bilder"][0]["Lank"]).and_return(nil)
    expect(Product.image_url(response)).to eq "undefined"
  end

end
