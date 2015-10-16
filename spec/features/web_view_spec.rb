require 'product_helper_spec'
# require 'pry'

feature 'Web View' do

  before do
    basic_auth('love', 'shack')
    visit "/admin"
    create_category
    create_brand
    add_product_web
  end

  context 'Categories' do
    scenario "visitors to the 'categories' route see a list of the categories in our database" do
      visit '/categories'
      expect(page).to have_content 'Categories'
      expect(page).to have_content 'Bröd'
    end
  end

  context 'Search' do
    xit scenario "visitors to the 'category' route see the products in an individual category in our database" do
      visit '/category' # TODO: Create route and code
      # TODO: Insert expectation here!
    end
  end

  context 'Product' do
    scenario "visitors to the 'product/:barcode' route see the product (if it's in our DB)" do
      visit '/product/1256256256526'
      expect(page).to have_content 'Product listing'
      expect(page).to have_content 'Lingongrova'
    end
  end

  context 'Product Image' do
    xit scenario "visitors to the 'product/:barcode' route see the product image (if it's in our DB)" do
      visit '/product/1256256256526'
      # TODO: Insert expectation here!
    end
  end

  context "Search by barcode" do
    scenario "Visitors to the 'search' route can search for and find products by barcode" do
      visit '/search/1256256256526'
      expect(page).to have_content 'Lingongrova'
    end
  end

  context "Search by brand name" do
    # FIXME: Failure/Error: visit '/search/Pågen': URI::InvalidURIError: URI must be ascii only "/search/P\u{e5}gen"
    xit scenario "Visitors to the 'search' route can search for and find products by brand" do
      visit '/search/Pågen'
      # binding.pry
      expect(page).to have_content 'Pågen'
    end
  end

  context "Search by category" do
    # FIXME: Failure/Error: visit '/search/Bröd': URI::InvalidURIError: URI must be ascii only "/search/Br\u{f6}d"
    xit scenario "Visitors to the 'search' route can search for and find products by category" do
      visit '/search/Bröd'
      # binding.pry
      expect(page).to have_content 'Bröd'
    end
  end

  context "Search by product name" do
    scenario "Visitors to the 'search' route can search for and find products by name" do
      visit '/search/Lingongrova'
      expect(page).to have_content 'Lingongrova'
    end
  end
end
