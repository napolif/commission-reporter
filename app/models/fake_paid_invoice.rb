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

class FakePaidInvoice < PaidInvoice
  after_initialize :populate

  def self.new_batch(size: 100, batch_num: PaidInvoice.next_batch_number)
    invoices = size.times.map do
      new(batch: batch_num)
    end
  end

  private

  def populate
    self.number = Faker::Number.number(digits: 6)
    self.sales_rep_code = self.class.sales_rep_codes.sample
    self.cases = Faker::Number.between(from: 15, to: 45)
    self.delivered = Faker::Boolean.boolean(true_ratio: 0.9)

    self.invoiced_on = Faker::Date.between(from: 120.days.ago, to: Date.today)
    self.paid_on = Faker::Date.between(from: invoiced_on, to: Date.today)

    self.customer_name = Faker::Restaurant.name
    self.customer_id = customer_name.gsub(' ', '').upcase.first(6)

    self.cost = Faker::Number.decimal(l_digits: 4, r_digits: 2)
    self.amount = Faker::Number.between(from: cost, to: cost * 1.25)
  end

  def self.sales_rep_codes
    @sales_rep_codes ||= SalesRep.all.pluck(:code)
  end
end
