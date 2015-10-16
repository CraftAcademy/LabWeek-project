require 'rubygems'
require 'csv'
require 'active_support/all'

############################
# This needs to be implemented in a Rakefile you can run on your server
# so treat this as a WIP.
#
# 1. you have to have your csv file formatted with the first row as headers
# 2. call this with 'CSVImport.import_with_headers('file.csv', 'Ingriedent')'
# Change 'Ingriedent' to whatever class name you are importing.
#
# A Hash will be created and passed in to the #create_instance
# method that will do the actual import to the database.
#
# You have to omit/take out the puts calls in the code if
# implementing in a Rakefile
#
############################

module CSVImport
  def self.import_with_headers(file, obj)
    import = CSV.read(file, quote_char: '"',
                      col_sep: ';',
                      row_sep: :auto,
                      headers: true,
                      header_converters: :symbol,
                      converters: :all).collect do |row|
      Hash[row.collect { |c, r| [c, r] }]
    end
    create_instance(obj, import)

  end

  def self.create_instance(obj, dataset)
    dataset.each do |data|
      begin
        instance = obj.constantize.create(category_id: data[:category_id], name: data[:name], is_parent: data[:is_parent], parent_id: data[:parent_id])
        puts "Created #{instance.name}"
      rescue
        puts "Could not save Category #{data[:name]}"
      end
    end
  end
end