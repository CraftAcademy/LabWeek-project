feature 'application setup' do
  feature 'root path' do

    scenario 'is successful' do
      visit '/'
      expect(page.status_code).to eq 200
    end
  end


end