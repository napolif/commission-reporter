# == Schema Information
#
# Table name: sales_reps
#
#  id         :bigint           not null, primary key
#  alpha_code :string
#  code       :string
#  comm1      :decimal(8, 2)
#  comm10     :decimal(8, 2)
#  comm2      :decimal(8, 2)
#  comm3      :decimal(8, 2)
#  comm4      :decimal(8, 2)
#  comm5      :decimal(8, 2)
#  comm6      :decimal(8, 2)
#  comm7      :decimal(8, 2)
#  comm8      :decimal(8, 2)
#  comm9      :decimal(8, 2)
#  disabled   :boolean          default(FALSE), not null
#  goal1      :decimal(8, 2)
#  goal10     :decimal(8, 2)
#  goal2      :decimal(8, 2)
#  goal3      :decimal(8, 2)
#  goal4      :decimal(8, 2)
#  goal5      :decimal(8, 2)
#  goal6      :decimal(8, 2)
#  goal7      :decimal(8, 2)
#  goal8      :decimal(8, 2)
#  goal9      :decimal(8, 2)
#  name       :string
#  period1    :decimal(8, 2)
#  period2    :decimal(8, 2)
#  period3    :decimal(8, 2)
#  period4    :decimal(8, 2)
#  period5    :decimal(8, 2)
#  quota_type :string
#  rep_type   :string           default("outside"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_sales_reps_on_code      (code) UNIQUE
#  index_sales_reps_on_disabled  (disabled)
#  index_sales_reps_on_rep_type  (rep_type)
#

# Info for a sales rep, including commission levels.
class SalesRep < ApplicationRecord
  include Importable

  DEFAULT_CODE = "_DEF".freeze

  QUOTA_TYPES = %w[profit revenue].freeze

  PERIODS_BY_AGE = {within_45:  "period1",
                    within_60:  "period2",
                    within_90:  "period3",
                    within_120: "period4",
                    over_120:   "period5"}.freeze

  validates :code, presence: true, uniqueness: {case_sensitive: false}, unless: :importing
  validates :name, presence: true
  validates :quota_type, inclusion: {in: QUOTA_TYPES}

  has_many :invoice_summaries, primary_key: "code", foreign_key: "sales_rep_code"
  has_many :invoice_headers, primary_key: "code", foreign_key: "rep_code"
  has_many :purged_records, primary_key: "code", foreign_key: "rep_code"

  before_validation { code.upcase! }

  scope :real, -> { where.not(code: DEFAULT_CODE) }

  def self.default
    @default ||= find_by(code: DEFAULT_CODE)
  end

  def self.default_new(code)
    default.dup.tap do |sr|
      sr.code = code
    end
  end

  def self.by_type(type)
    return real if type == "all"

    where(rep_type: type).real
  end

  def self.codes
    select(:code).pluck(:code)
  end

  def self.existing_rep_types
    ["all"] + real.select(:rep_type).distinct.pluck(:rep_type).sort
  end

  def commission_table
    (1..10).map do |i|
      [i, self["goal#{i}"], self["comm#{i}"]]
    end
  end

  def last_name
    name.split.second
  end
end
