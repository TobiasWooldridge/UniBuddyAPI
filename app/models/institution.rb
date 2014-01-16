class Institution < ActiveRecord::Base
  has_many :buildings, :dependent => :destroy


  class << self # Class methods
    def flinders()
      Institution.where(:name => "Flinders University").first
    end
  end
end
