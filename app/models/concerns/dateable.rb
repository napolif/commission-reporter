# Adds a `created_date` field & methods for querying the max and min.
module Dateable
  extend ActiveSupport::Concern

  included do
    validates :created_date, presence: true
  end

  class_methods do
    def max_created_date
      where.not(created_date: nil).order(created_date: :desc).first&.created_date
    end

    def min_created_date
      where.not(created_date: nil).order(:created_date).first&.created_date
    end
  end
end
