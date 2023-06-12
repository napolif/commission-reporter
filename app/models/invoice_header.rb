# == Schema Information
#
# Table name: invoice_headers
#
#  id            :bigint           not null, primary key
#  amount        :decimal(10, 2)
#  cost          :decimal(10, 2)
#  customer_code :string
#  number        :string
#  order_date    :date
#  qty_ord       :integer
#  rep_code      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_invoice_headers_on_customer_code  (customer_code)
#  index_invoice_headers_on_number         (number) UNIQUE
#  index_invoice_headers_on_rep_code       (rep_code)
#

# Information about a single invoice (either Alpha or Retalix), not counting line items.
class InvoiceHeader < ApplicationRecord
  include Importable
  include Dateable

  before_validation { customer_code&.upcase! }
  before_validation { rep_code&.upcase! }

  validates :amount, presence: true
  validates :cost, presence: true
  validates :number, presence: true, uniqueness: true, unless: :importing
  validates :order_date, presence: true
  validates :rep_code, presence: true

  belongs_to :customer, primary_key: "code", foreign_key: "customer_code", optional: true
  belongs_to :sales_rep, primary_key: "code", foreign_key: "rep_code", optional: true
  has_many :purged_records, primary_key: "number", foreign_key: "invoice_number"

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

  def source
    number.to_i < 790000 ? :alpha : :retalix
  end
end
