# == Schema Information
#
# Table name: invoice_summaries
#
#  id             :bigint           not null, primary key
#  amount         :decimal(8, 2)
#  batch          :string
#  cases          :integer
#  cost           :decimal(8, 2)
#  customer_code  :string
#  customer_name  :string
#  delivered      :boolean
#  invoiced_on    :date
#  number         :string
#  paid_on        :date
#  sales_rep_code :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_invoice_summaries_on_batch                     (batch)
#  index_invoice_summaries_on_batch_and_sales_rep_code  (batch,sales_rep_code)
#  index_invoice_summaries_on_number                    (number)
#  index_invoice_summaries_on_sales_rep_code            (sales_rep_code)
#

# Derived data about invoice and its possible payment.
# Comes from COMMFILE in naplib, which has one line per invoice.
# An invoice can be open (RDATE is zero) or closed (valid RDATE).
#
# Adjustments also have their own invoice numbers and are always closed.
#
# Ideally we would use these records in all cases, but invoices that are only in
# Alpha don't show up here, even if paid.
class InvoiceSummary < ApplicationRecord
  validates :batch, presence: true
  validates :number, presence: true, uniqueness: true
  validates :sales_rep_code, presence: true
  validates :invoiced_on, presence: true
  # validates :paid_on, presence: true
  validates :amount, presence: true
  validates :cost, presence: true

  belongs_to :sales_rep, primary_key: "code", foreign_key: "sales_rep_code", optional: true

  scope :latest_batch, -> { where(batch: latest_batch_number) }

  before_validation { sales_rep_code&.upcase! }

  def self.latest_batch_number
    order(created_at: :desc).limit(1).pluck(:batch).first
  end

  def self.next_batch_number
    DateTime.now.utc.to_s.sub(" UTC", "").sub(" ", "-").gsub(":", "")
  end

  def self.batch_numbers
    pluck(:batch, :created_at)
      .uniq(&:first)
      .sort_by(&:second)
      .reverse
      .transpose
      .first || []
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
