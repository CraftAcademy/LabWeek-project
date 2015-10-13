require 'product'
require 'product_helper_spec'
#require 'pry'

describe Product do

  it { is_expected.to have_property :id }
  it { is_expected.to have_property :product_name }
  it { is_expected.to have_property :barcode }
  it { is_expected.to have_property :sugar_content_gram }
  it { is_expected.to have_property :ranking }

  it { is_expected.to validate_presence_of :product_name }
  it { is_expected.to validate_presence_of :barcode }
  it { is_expected.to validate_uniqueness_of :barcode }
  xit { is_expected.to validate_presence_of :sugar_content_gram }

  it 'a product can be created' do
    create_products
    expect(Product.first.product_name).to eq "Lingongrova"
  end

  it 'have no ranking when created' do
    create_products
    expect(Product.first.ranking).to eq nil
  end

  it 'running update rankning method sets ranking' do
    create_products
    Product.update_ranking
    expect(Product.first.ranking).to eq 2
  end

  it 'can find a product in the database' do
    create_products
    expect(Product.find_product("1212526767678").id).to eq 3
  end

  it 'can convert a 13 digit barcode to dabas 14 digit GTIN' do
    expect(Product.dabas_barcode("1212526767678")).to eq "01212526767678"
  end

end
