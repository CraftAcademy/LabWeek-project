require 'dabas_id'
require 'product_helper_spec'

describe Dabasid do

  it { is_expected.to have_property :id }
  it { is_expected.to have_property :name }

  it { is_expected.to belong_to :category }

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_uniqueness_of :name }
end