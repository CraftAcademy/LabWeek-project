require 'product'
require 'product_helper_spec'

describe Product do

  it { is_expected.to have_property :id }
  it { is_expected.to have_property :product_name }
  it { is_expected.to have_property :barcode }
  it { is_expected.to have_property :sugar_content_gram }
  it { is_expected.to have_property :ranking }

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

  it 'running update rankning method sets ranking' do
    create_products
    Product.update_ranking
    expect(Product.first.ranking).to eq 2
  end


end