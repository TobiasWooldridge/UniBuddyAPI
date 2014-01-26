class ClassGroup < ActiveRecord::Base
  belongs_to :class_type
  belongs_to :selection_sync

  has_many :activities, :dependent => :destroy

  def as_json(options = {})
    {
      id: id,
      group_id: group_number,
      note: note,
      full: full,
      activities: activities,
      selection_sync: selection_sync
    }
  end
end
