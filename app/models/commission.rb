# Calculation of a commission amount for a given invoice & associated sales rep.
class Commission
  attr_reader :invoice, :sales_rep, :purged

  delegate :created_date, to: :purged
  delegate :order_date, to: :invoice
  delegate :margin_pct, to: :invoice
  delegate :commission_table, to: :sales_rep

  def initialize(purged_record)
    @purged = purged_record
    @invoice = purged.invoice_header
    @sales_rep = invoice.sales_rep || SalesRep.default_new(invoice.rep_code)
  end

  # Returns the commission for the associated invoice in dollars.
  def amount
    adjusted = adjusted_pct / 100

    case sales_rep.quota_type
    when "revenue"
      adjusted * invoice.amount
    when "profit"
      adjusted * invoice.profit
    else
      adjusted * invoice.profit
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
    wait_days = (created_date - order_date).to_i
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
end
