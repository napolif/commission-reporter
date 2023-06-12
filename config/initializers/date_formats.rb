# this is an alias of DATE_FORMATS[:number]
Date::DATE_FORMATS[:retalix] = "%Y%m%d"

class Date
  def self.from_retalix(val)
    strptime(val, DATE_FORMATS[:retalix])
  end

  def retalix
    to_formatted_s(:retalix)
  end
end
