class ClassGroup < ActiveRecord::Base
  belongs_to :class_type

  belongs_to :synced_selection

  has_many :activities, :dependent => :destroy

  def as_json(options = {})
    {
      id: id,
      group_id: group_number,
      note: note,
      full: full,
      activities: activities,
      synced_selection: synced_selection
    }
  end
end
