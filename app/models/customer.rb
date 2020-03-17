# == Schema Information
#
# Table name: customers
#
#  id         :bigint           not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_customers_on_code  (code) UNIQUE
#

# Information about a particular customer. Used to look up full name.
class Customer < ApplicationRecord
  include Importable

  before_validation { code&.upcase! }

  validates :code, presence: true, uniqueness: true, unless: :importing
  validates :name, presence: true
end
