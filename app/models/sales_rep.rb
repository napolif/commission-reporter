class SalesRep < ApplicationRecord
  validates :code, presence: true, uniqueness: {case_sensitive: false}
  validates :name, presence: true
end
