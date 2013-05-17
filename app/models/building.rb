class Building < ActiveRecord::Base
  attr_accessible :name, :code

  has_many :rooms, :dependent => :destroy
end
