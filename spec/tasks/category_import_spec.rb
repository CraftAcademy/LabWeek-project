require 'rake'
describe 'Rake tasks' do
  describe 'setup:category_import' do
    before do
      load 'tasks/category_import.rake'
      Rake::Task.define_task(:environment)
    end

    it 'should create instances of Category' do
      count = CSV.read('./import/bageri.csv').length - 1 #compensate for headers
      expect { Rake::Task['setup:category_import'].invoke }.to change(Category, :count).by count
    end
  end
end