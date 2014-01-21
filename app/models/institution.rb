class Institution < ActiveRecord::Base
  has_many :buildings, :dependent => :destroy

  def as_json(options = {})
    to_h
  end

  def to_h()
    {
      code: code,
      name: name,
      nickname: nickname,
      country: country,
      state: state
    }
  end

  class << self
    def flinders()
      Institution.where(:code => "flinders").first
    end

    def adelaide()
      Institution.where(:code => "adelaide").first
    end
  end
end
