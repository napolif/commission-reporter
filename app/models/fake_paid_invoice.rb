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

# Convenience class for generating a PaidInvoice with fake information.
class FakePaidInvoice < PaidInvoice
  after_initialize :populate

  def self.new_batch(size: 100, batch_num: PaidInvoice.next_batch_number)
    size.times.map do
      new(batch: batch_num)
    end
  end

  def self.sales_rep_codes
    @sales_rep_codes ||= SalesRep.all.pluck(:code)
  end

  def populate # rubocop:disable Metrics/AbcSize
    invoiced_on = Faker::Date.between(from: 120.days.ago, to: Date.today)
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
      customer_id: customer_name.gsub(" ", "").upcase.first(6),
      cost: cost,
      amount: Faker::Number.between(from: cost, to: cost * 1.25)
    )
  end
end
