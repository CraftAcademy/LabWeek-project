require 'product_helper_spec'
require 'pry'

feature 'Web View' do

  before do
    basic_auth('love', 'shack')
    visit "/admin"
    create_category
    create_brand
    add_product_web
  end

  scenario "visitors to the 'categories' route see what categories are in our database" do

    visit '/categories'
    # @category = Category.all
    # binding.pry
    expect(page).to have_content 'Categories'
    expect(page).to have_content 'Bröd'

  end
end
