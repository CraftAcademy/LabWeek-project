class Dabasid

  include DataMapper::Resource

  property :id, Serial
  property :name, String

  belongs_to :category

  validates_presence_of :name, message: "Please fill in category name."
  validates_uniqueness_of :name, message: "Category already exists."

end
