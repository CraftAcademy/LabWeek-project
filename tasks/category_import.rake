namespace :setup do
  require './lib/love.rb'
  require './lib/csv_import.rb'

  desc 'Import categories to db'
  task :category_import do
    CSVImport.import_with_headers('./import/bageri.csv', 'Category')
end
end