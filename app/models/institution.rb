class Institution < ActiveRecord::Base
  has_many :buildings, :dependent => :destroy


  class << self # Class methods
    def flinders()
      Institution.where(:code => "flinders").first
    end
  end
end
