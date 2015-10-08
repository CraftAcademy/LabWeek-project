require 'category'

describe Category do

  it { is_expected.to have_property :id }
  it { is_expected.to have_property :name }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_uniqueness_of :name }

  it 'a category can be created' do
    create_category
    expect(Category.first.name).to eq "Bröd"
  end

end