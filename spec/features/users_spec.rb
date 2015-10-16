feature "Join" do
  before do
    visit "join"
  end

  scenario "creates new user with valid inputs" do

    expect(User.count).to eq 0
    fill_in "name", with: "Bo"
    fill_in "user_name", with: "botte"
    fill_in "email", with: "bo@cint.com"
    fill_in "password", with: "password"
    fill_in "password_confirm", with: "password_confirm"
    click_button 'Join here!'
    expect(User.count).to eq 1
  end

  describe 'Password encryption' do
    it 'encrypts password' do
      user = User.create(name: 'Bo', user_name: 'botte', email: 'bo@cint.com', password: 'password', password_confirm: 'password')
      expect(user.password_digest.class).to eq BCrypt::Password
      expect(user.password_digest.version).to eq '2a'
    end
  end

  # not very dry.....user.create used at three different places
  scenario 'allows a new user to join the service with valid credentials' do
    User.create(name: 'Bo', user_name: 'botte', email: 'bo@cint.com', password: 'password', password_confirm: 'password')
    visit 'join'
    fill_in 'email', with: 'bo@cint.com'
    fill_in 'password', with: 'password'
    click_button 'Join here!'
    expect(page.current_path).to eq '/join'
   # expect(page).to have_content 'Welcome Bo!' Needs fixing.
  end

  feature 'Sign Out' do
    scenario 'signs the user out when she clicks Sign out button' do
      User.create(name: 'Bo', user_name: 'botte', email: 'bo@cint.com', password: 'password', password_confirm: 'password')
      visit '/sign_out'
      expect(page).to have_content 'Thanks for visiting, hope to see you soon again!'
    end
  end
end



