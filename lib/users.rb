require 'bcrypt'

class User

  attr_accessor :password, :password_confirm

  include DataMapper::Resource
  include BCrypt

  property :id,                  Serial
  property :name,                String, length: 255
  property :user_name,           String, length: 30
  property :email,               String, format: :email_address, unique: true, message: "This email is already taken"
  property :password_confirm,    Text, length: 255
  property :password_digest,     Text, length: 255
  property :created_at,          DateTime

  validates_presence_of :name
  validates_presence_of :user_name
  validates_presence_of :email

  before :save do
    if self.password == self.password_confirm
      self.password_digest = BCrypt::Password.create(self.password)
    else
    end
  end

  def self.authenticate(email, password)
    user = first(email: email)
    if user && BCrypt::Password.new(user.password_digest) == password
      user
    else
      nil
    end
  end

end
