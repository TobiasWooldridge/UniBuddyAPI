class ClassGroup < ActiveRecord::Base
  belongs_to :class_type

  has_many :class_sessions
end
