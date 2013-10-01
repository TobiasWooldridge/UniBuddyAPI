class ClassSession < ActiveRecord::Base
  belongs_to :class_group

  def day_of_week_name
    (Time.now.at_beginning_of_week + (day_of_week - 1).days).strftime("%A") 
  end

  def as_json(options = {})
    {
      first_day: first_day,
      last_day: last_day,
      day_of_week: day_of_week_name,
      time_starts_at: seconds_to_time(time_starts_at),
      time_ends_at: seconds_to_time(time_ends_at),
      seconds_starts_at: time_starts_at,
      seconds_ends_at: time_ends_at,
      seconds_duration: seconds_duration
    }
  end

  def seconds_duration
    time_ends_at - time_starts_at
  end

  private
  def seconds_to_time seconds
    (Time.now.at_beginning_of_day + seconds).strftime("%l:%M %p").squish
  end
end
