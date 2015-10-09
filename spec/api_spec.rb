require 'product'
# require 'pry'
require 'product_helper_spec'

describe 'API' do

  let(:json) { JSON.parse(page.text) }

  before do
    create_products
  end

  context 'GET /api/v1/product_listing' do
    it "should return ALL listings as JSON" do
      visit '/api/v1/product_listing'
      expect(json.length).to eq(4)
      expect(json.class).to eq(Array)
      expect(json[0].class).to eq(Hash)
      expect(json[0]['product_name']).to eq('Lingongrova')
      expect(json[1]['product_name']).to eq('Tekaka')
      expect(json[2]['product_name']).to eq('Rågbröd')
      expect(json[3]['product_name']).to eq('Rostbröd')
    end
  end

  context 'GET /api/v1/product_listing/:barcode' do
    it "should return a SINGLE listing as JSON" do
      visit '/api/v1/product_listing?barcode=1212526767676'
      # binding.pry
      expect(json[0]['product_name']).to eq('Lingongrova')
    end
  end
end
