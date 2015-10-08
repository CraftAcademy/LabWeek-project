require 'product'
require 'pry'
require 'product_helper_spec'

describe 'GET /api/v1/product_listing' do

  let(:json) { JSON.parse(page.text) }

  before do
    create_products
  end

  it "should return all listings as JSON" do
    visit '/api/v1/product_listing'
    # binding.pry
    expect(json.length).to eq(4)
    expect(json.class).to eq(Array)
    expect(json[0].class).to eq(Hash)
    expect(json[0]['product_name']).to eq('Lingongrova')
    expect(json[1]['product_name']).to eq('Tekaka')
    expect(json[2]['product_name']).to eq('Rågbröd')
    expect(json[3]['product_name']).to eq('Rostbröd')
  end
end
