class PaidInvoice
  include ActiveModel::Model
  include ActiveModel::AttributeMethods

  attr_accessor :number, :salesrep_id, :invoiced_on, :paid_on, :amount, :cost, :cases, :delivered

  attribute_method_suffix '_pct'
  define_attribute_methods 'margin', 'markup'

  def amount=(val)
    @amount = BigDecimal(val, 10)
  end

  def cost=(val)
    @cost = BigDecimal(val, 10)
  end

  def profit
    amount - cost
  end

  def markup
    profit / cost
  end

  def margin
    profit / amount
  end

  private

  def attribute_pct(attribute)
    send(attribute) * 100
  end
end
