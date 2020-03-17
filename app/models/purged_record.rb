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

class PurgedRecord < ApplicationRecord
  include Importable

  validates :amount, presence: true
  validates :created_date, presence: true
  validates :invoice_number, presence: true
  validates :invoice_type, inclusion: {in: 1..4}

  belongs_to :invoice_header, foreign_key: "invoice_number", primary_key: "number", optional: true
end
