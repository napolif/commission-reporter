# == Schema Information
#
# Table name: paid_invoices
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

class PaidInvoice < ApplicationRecord
  validates :batch, presence: true
  validates :number, presence: true
  validates :sales_rep_code, presence: true # TODO: upcase
  validates :invoiced_on, presence: true
  validates :paid_on, presence: true
  validates :amount, presence: true
  validates :cost, presence: true

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
    profit / amount
  end

  def margin_pct
    100 * margin
  end
end
