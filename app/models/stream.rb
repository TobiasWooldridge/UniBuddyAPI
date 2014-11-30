class Stream < ActiveRecord::Base
  belongs_to :topic

  def as_json(options = {})
    {
        id: id,
        name: name,
        streamGroup: topic_id.to_s(16) # Hex encoding the topic ID so nobody uses this as topic ID (it could change in future)
    }
  end
end
