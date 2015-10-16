require 'users'
require 'bcrypt'


describe User do
  it { is_expected.to have_property :id }
  it { is_expected.to have_property :email }
  it { is_expected.to have_property :password_digest}
  it { is_expected.to validate_format_of(:email).with(:email_address) }
  it { is_expected.to validate_uniqueness_of :email }
  it { is_expected.to validate_presence_of :email }


  describe "User auth" do
    before do
      @user = User.create(name: 'Bo', user_name: 'botte', email: 'bo@cint.com', password: 'password', password_confirm: 'password')
    end

    it "With valid credentials" do
      expect(User.authenticate('bo@cint.com', 'password')).to eq @user
    end

    it "With invalid credentials" do
      expect(User.authenticate('bo@cint.com', 'other-password')).to eq nil
    end
  end

end


