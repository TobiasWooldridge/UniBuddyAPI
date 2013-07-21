module ApplicationHelper

  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Flinders Helper"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  def limited_time_until(free_until)
    if free_until == Time.now.at_end_of_day
      return "The rest of the day"
    end

    return distance_of_time_in_words_to_now free_until
  end
end