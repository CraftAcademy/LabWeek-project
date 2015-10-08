class Category

  include DataMapper::Resource

  property :id, Serial
  property :name, String

  has n, :products, through: Resource

  validates_presence_of :name, message: "Please fill in category name."
  validates_uniqueness_of :name, message: "Category already exists."

end