class ClassType < ActiveRecord::Base
  belongs_to :topic

  has_many :class_group

  def as_json(options = {})
    {
      name: name,
      note: note,
      class_groups: class_group
    }
  end
end
