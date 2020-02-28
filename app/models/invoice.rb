# == Schema Information
#
# Table name: invoices
#
#  id             :bigint           not null, primary key
#  batch          :string
#  number         :string
#  sales_rep_code :string
#  invoiced_on    :date
#  paid_on        :date
#  amount         :decimal(8, 2)
#  cost           :decimal(8, 2)
#  customer_id    :string
#  customer_name  :string
#  cases          :integer
#  delivered      :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

# Header for an invoice.
class Invoice < ApplicationRecord
  validates :batch, presence: true
  validates :number, presence: true
  validates :sales_rep_code, presence: true
  validates :invoiced_on, presence: true
  validates :paid_on, presence: true
  validates :amount, presence: true
  validates :cost, presence: true

  belongs_to :sales_rep, primary_key: "code", foreign_key: "sales_rep_code", optional: true

  scope :latest_batch, -> { where(batch: latest_batch_number) }

  before_validation { sales_rep_code.upcase! }

  def self.latest_batch_number
    Invoice.order(created_at: :desc).limit(1).pluck(:batch).first
  end

  def self.next_batch_number
    DateTime.now.utc.to_s.sub(" UTC", "").sub(" ", "-").gsub(":","")
  end

  def self.batch_numbers
    Invoice.
      pluck(:batch, :created_at).
      uniq(&:first).
      sort_by(&:second).
      reverse.
      transpose.
      first
  end

  def amount=(val)
    super BigDecimal(val, 8)
  end

  def cost=(val)
    super BigDecimal(val, 8)
  end

  def profit
    amount - cost
  end

  def margin
    return 0 if amount.zero?
    profit / amount
  end

  def margin_pct
    100 * margin
  end

  def age_category
    wait_days = (paid_on - invoiced_on).to_i
    raise "Error: invoice #{id} paid_on before invoiced_on" if wait_days.negative?

    case wait_days
    when 0..45
      :within_45
    when 45..60
      :within_60
    when 61..90
      :within_90
    when 90..120
      :within_120
    else
      :over_120
    end
  end
end
