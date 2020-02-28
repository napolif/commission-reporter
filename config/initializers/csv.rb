class CSV
  class Row
    def get(key)
      fetch(key)&.strip
    end
  end
end
