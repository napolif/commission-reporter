# == Schema Information
#
# Table name: sales_reps
#
#  id         :bigint           not null, primary key
#  code       :string
#  name       :string
#  comm_type  :string
#  period1    :decimal(8, 2)
#  period2    :decimal(8, 2)
#  period3    :decimal(8, 2)
#  period4    :decimal(8, 2)
#  period5    :decimal(8, 2)
#  goal1      :decimal(8, 2)
#  goal2      :decimal(8, 2)
#  goal3      :decimal(8, 2)
#  goal4      :decimal(8, 2)
#  goal5      :decimal(8, 2)
#  goal6      :decimal(8, 2)
#  goal7      :decimal(8, 2)
#  goal8      :decimal(8, 2)
#  goal9      :decimal(8, 2)
#  goal10     :decimal(8, 2)
#  comm1      :decimal(8, 2)
#  comm2      :decimal(8, 2)
#  comm3      :decimal(8, 2)
#  comm4      :decimal(8, 2)
#  comm5      :decimal(8, 2)
#  comm6      :decimal(8, 2)
#  comm7      :decimal(8, 2)
#  comm8      :decimal(8, 2)
#  comm9      :decimal(8, 2)
#  comm10     :decimal(8, 2)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class SalesRep < ApplicationRecord
  validates :code, presence: true, uniqueness: {case_sensitive: false}
  validates :name, presence: true

  has_many :paid_invoices, primary_key: "code", foreign_key: "sales_rep_code"

  before_validation { code.upcase! }

  PERIODS_BY_AGE = { within_45:  "period1",
                     within_60:  "period2",
                     within_90:  "period3",
                     within_120: "period4",
                     over_120:   "period5" }

  def commission_table
    (1..10).map do |i|
      [i, self["goal#{i}"], self["comm#{i}"]]
    end
  end

  def last_name
    name.split.second
  end
end
