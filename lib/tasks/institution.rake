namespace :institution do
  task :create, [:name, :nickname, :country, :state, :code]  => :environment do |t, args|
    Institution.create(:name => args[:name], :nickname => args[:nickname], :country => args[:country], :state => args[:state], :code => args[:code])
  end
end
