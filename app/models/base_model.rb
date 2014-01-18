class BaseModel < ActiveRecord::Base
  self.abstract_class = true

  def self.pluck_h (*columns)
    topics = []

    retrieved_rows = self.pluck(*columns)
    retrieved_rows.each do |row|
      topic = {}

      if columns.length > 1
        columns.each_with_index do |column, index|
          topic[column] = row[index]
        end
      else
        topic[columns.first] = row
      end

      topics.append(topic)
    end

    return topics
  end

  def self.for_institution(inst_code)
    self.joins(:institution).where(:institutions => { :code => inst_code })
  end
end