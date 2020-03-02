# == Schema Information
#
# Table name: invoices
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
#  index_invoices_on_batch                     (batch)
#  index_invoices_on_batch_and_sales_rep_code  (batch,sales_rep_code)
#  index_invoices_on_number                    (number)
#  index_invoices_on_sales_rep_code            (sales_rep_code)
#

# Convenience class for generating a Invoice with fake information.
class FakeInvoice < Invoice
  after_initialize :populate

  def self.new_batch(size: 100, batch_num: Invoice.next_batch_number)
    size.times.map do
      new(batch: batch_num)
    end
  end

  def self.create_batch(size: 100, batch_num: Invoice.next_batch_number)
    a_batch = new_batch(size: size, batch_num: batch_num + "-fake")
    Invoice.import!(a_batch)
    a_batch
  end

  def self.sales_rep_codes
    @sales_rep_codes ||= SalesRep.all.pluck(:code).without(SalesRep::DEFAULT_CODE)
  end

  def populate # rubocop:disable Metrics/AbcSize
    invoiced_on = Faker::Date.between(from: 14.days.ago, to: Date.today)
    customer_name = Faker::Restaurant.name
    cost = Faker::Number.decimal(l_digits: 4, r_digits: 2)

    assign_attributes(
      number: Faker::Number.number(digits: 6),
      sales_rep_code: self.class.sales_rep_codes.sample,
      cases: Faker::Number.between(from: 15, to: 45),
      delivered: Faker::Boolean.boolean(true_ratio: 0.9),
      invoiced_on: invoiced_on,
      paid_on: Faker::Date.between(from: invoiced_on, to: Date.today),
      customer_name: customer_name,
      customer_code: customer_name.gsub(" ", "").upcase.first(6),
      cost: cost,
      amount: Faker::Number.between(from: cost, to: cost * 1.25)
    )
  end
end
