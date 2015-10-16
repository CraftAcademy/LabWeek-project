namespace :dm do
  desc 'Perform auto migration (reset your db data)'
  task :migrate do
    ::DataMapper.repository.auto_migrate!
    puts 'executed dm:auto:migrate'
  end

  desc 'Perform non destructive auto migration'
  task :upgrade do
    ::DataMapper.repository.auto_upgrade!
    puts 'executed dm:auto:upgrade'
  end
end