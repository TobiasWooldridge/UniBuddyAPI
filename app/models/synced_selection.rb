class SyncedSelection < ActiveRecord::Base
  belongs_to :topic

  def to_json(options = {})
    {
        id: id
    }
  end
end
