class ClassType < ActiveRecord::Base
  belongs_to :topic

  has_many :class_group, :dependent => :destroy

  def as_json(options = {})
    {
      id: id,
      name: name,
      note: note,
      class_groups: class_group
    }
  end
end
