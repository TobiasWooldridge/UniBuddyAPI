class ClassType < ActiveRecord::Base
  belongs_to :topic

  has_many :class_group
end
