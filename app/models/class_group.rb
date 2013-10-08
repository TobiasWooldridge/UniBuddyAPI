class ClassGroup < ActiveRecord::Base
  belongs_to :class_type

  has_many :class_sessions, :dependent => :destroy

  def as_json(options = {})
    {
      id: id,
      group_id: group_number,
      note: note,
      full: full,
      class_sessions: class_sessions
    }
  end
end
