# == Schema Information
#
# Table name: purged_records
#
#  id             :bigint           not null, primary key
#  adj_code       :string
#  amount         :decimal(10, 2)
#  created_date   :date
#  customer_code  :string
#  due_date       :date
#  invoice_number :string
#  invoice_type   :integer          default(1), not null
#  ref_number     :string
#  rep_code       :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_purged_records_on_adj_code        (adj_code)
#  index_purged_records_on_invoice_number  (invoice_number)
#  index_purged_records_on_rep_code        (rep_code)
#

# An entry in the Retalix "A/R Purged Detail" file.
#
# A single invoice will typically have multiple entries in this file, e.g.: an entry for
# the amount owed, and an entry for the amount paid. Invoices do not appear in this file
# unless they are fully paid.
class PurgedRecord < ApplicationRecord
  include Importable

  validates :amount, presence: true
  validates :created_date, presence: true
  validates :invoice_number, presence: true
  validates :invoice_type, inclusion: {in: 1..4}

  belongs_to :invoice_header, foreign_key: "invoice_number", primary_key: "number", optional: true

  scope :payments, -> { where(invoice_type: 2) }
  scope :invoice_numbers, -> { select(:invoice_number) }
  scope :with_present_invoices, -> {
    includes(:invoice_header).where.not(invoice_headers: {id: nil})
  }

  def self.for_dates_and_reps(dates, rep_codes)
    subquery = where(created_date: dates).with_present_invoices.invoice_numbers

    includes(invoice_header: [:sales_rep, :customer])
      .where(invoice_number: subquery)
      .where(rep_code: rep_codes)
      .payments
  end
end
