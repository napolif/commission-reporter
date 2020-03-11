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
#  index_invoice_headers_on_number         (number)
#  index_invoice_headers_on_rep_code       (rep_code)
#

class InvoiceHeader < ApplicationRecord
end
