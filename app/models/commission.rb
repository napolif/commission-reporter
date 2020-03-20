# Calculation of a commission amount for a given invoice & associated sales rep.
class Commission
  attr_reader :invoice, :sales_rep, :purged_records

  delegate :order_date, to: :invoice
  delegate :margin_pct, to: :invoice
  delegate :commission_table, to: :sales_rep
  delegate :quota_type, to: :sales_rep

  def initialize(purged_records)
    @purged_records = purged_records
    @invoice = purged_records.first.invoice_header
    @sales_rep = invoice.sales_rep || SalesRep.default_new(invoice.rep_code)
  end

  # Returns the commission information as an array for use with CSV export.
  def as_csv # rubocop:disable Metrics/AbcSize
    i = invoice
    r = sales_rep

    [
      i.number, i.customer_code, i.customer.name, i.order_date,
      paid_date, age_category, paid_amount, i.cost,
      pretty_num(i.margin_pct), i.qty_ord,
      r.code, r.name, r.quota_type, pretty_num(amount)
    ]
  end

  def paid_date
    purged_records.map(&:created_date).max
  end

  def paid_amount
    payments = purged_records.select { |rec| rec.invoice_type == 2 }
    return 0 unless payments.present?

    payments.map(&:amount).reduce(:+)
  end

  # TODO: figure out what works best for this
  def ratio
    return 0 if invoice.amount.zero?
    paid_amount / invoice.amount
  end

  def adjusted_cost
    invoice.cost * ratio
  end

  def profit
    invoice.profit * ratio
  end
  # ------------------------------------------

  # Returns the commission for the associated invoice in dollars.
  def amount
    adjusted = adjusted_pct / 100

    case quota_type
    when "revenue"
      adjusted * paid_amount
    when "profit"
      adjusted * profit
    else
      adjusted * profit
    end
  end

  # Returns the base commission adjusted for invoice payment age.
  def adjusted_pct
    base_pct * (age_adjustment_pct / 100)
  end

  # Returns the base commission % for the matching level.
  def base_pct
    return 0 unless level

    _index, _goal, pct = level
    pct
  end

  # Returns the rep's highest commission level (table row) where the minimum is
  # greater than the invoice's GP%.
  def level
    commission_table.reverse.find do |_i, goal, _comm|
      margin_pct >= goal
    end
  end

  # Returns the commission adjustment given the invoice payment age.
  def age_adjustment_pct
    period = SalesRep::PERIODS_BY_AGE[age_category]
    sales_rep[period]
  end

  def age_category
    wait_days = (paid_date - order_date).to_i
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

  def pretty_num(bigdec)
    "%.2f" % bigdec.to_f
  end

  def pretty_bool(bool)
    bool ? "yes" : "no"
  end
end
