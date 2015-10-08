require 'product_helper_spec'

feature 'application setup' do
  feature 'root path' do

    scenario 'is successful' do
      visit '/'
      expect(page.status_code).to eq 200
    end
  end
end

feature 'basic HTTP authorization' do

  scenario 'unauthorized visitors denied access to protected routes' do
    visit '/protected'
    expect(page.status_code).to eq 401
  end

  scenario 'users submitting wrong credentials denied access to protected routes' do
    basic_auth('ajja bajja', 'ajja bajja')
    visit '/protected'
    expect(page.status_code).to eq 401
  end

  scenario 'users submitting correct credentials allowed access to protected routes' do
    basic_auth('love', 'shack')
    visit '/protected'
    expect(page.status_code).to eq 200
  end
end

feature "get fill out form" do
  before do
    basic_auth('love', 'shack')
    visit "/admin"
  end

  scenario "creates fill out form" do
    expect(page).to have_selector "form[action='/fill_out']"
    expect(page).to have_selector "form[method='post']"
    expect(page).to have_selector "input[name='brand']"
    expect(page).to have_selector "input[name='product_name']"
    expect(page).to have_selector "input[name='category']"
    expect(page).to have_selector "input[name='barcode']"
    expect(page).to have_selector "input[name='sugar_content_gram']"
  end

  xscenario 'admin user can add a new product' do
    visit "/admin"
    fill_in 'brand', with: 'Pågen'
    fill_in 'product_name', with: 'Lingongrova'
    fill_in 'category', with: 'Mjukt bröd'
    fill_in 'barcode', with: '1256256256526'
    fill_in 'sugar_content_gram', with: '8.5'
    click_button 'Add product'
    expect(page.status_code).to eq 200
    expect(page.current_path).to eq '/admin/product_listing'
    expect(page).to have_content 'Lingongrova'
  end

  xscenario 'admin can view the product listing' do
    visit "/admin"
    add_product_web
    expect(page.status_code).to eq 200
    expect(page.current_path).to eq '/admin/product_listing'
    expect(page).to have_content 'Brand'
    expect(page).to have_content 'Product name'
    expect(page).to have_content 'Category'
    expect(page).to have_content 'Barcode'
    expect(page).to have_content 'Sugar/100g'
    expect(page).to have_content 'Ranking'
    expect(page).to have_content 'Delete'
    expect(page).to have_content 'Update'
  end

  xscenario 'admin can delete a product' do
    visit "/admin"
    add_product_web
    click_on 'Delete'
    expect(page.status_code).to eq 200
    expect(page.current_path).to eq '/admin/product_listing'
    expect(page).to have_content 'No links in the system'
  end

  xscenario 'show update form' do
    visit "/admin"
    add_product_web
    click_on 'Update'
    expect(page.status_code).to eq 200
    expect(page).to have_content 'Update product'
  end

end
