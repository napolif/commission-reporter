# Calculation of a commission amount for a given invoice & associated sales rep.
class Commission
  attr_reader :invoice, :sales_rep, :purged_records

  delegate :number, to: :invoice
  delegate :order_date, to: :invoice
  delegate :margin_pct, to: :invoice
  delegate :commission_table, to: :sales_rep
  delegate :quota_type, to: :sales_rep

  def self.for_invoice(num)
    new InvoiceHeader.find_by(number: num).purged_records
  end

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
      i.number, i.customer_code, i.customer.name, order_date,
      paid_date, age_category, i.amount, paid_amount, pretty_num(i.cost),
      pretty_num(adjusted_cost), pretty_num(paid_fraction),
      pretty_num(i.margin_pct), i.qty_ord,
      r.code, r.name, r.quota_type, pretty_num(amount)
    ]
  end

  # Returns the commission to be paid in dollars.
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
    period = SalesRep::PERIODS_BY_AGE[age_category]
    age_adjustment_pct = sales_rep[period]
    base_pct * (age_adjustment_pct / 100)
  end

  # The dollar amount used as a base for calculating commission. This is typically
  # the same as real_paid_amount.
  def paid_amount
    # For alpha invoices, because some were paid across both systems, if real_paid_amount
    # is lower, we just trust the invoice header sales total.
    if invoice.source == :alpha && real_paid_amount < invoice.amount
      return invoice.amount
    end

    # for retalix invoices, if the paid amount was zero, use zero
    return 0 if real_paid_amount.zero?

    # otherise use the paid amount, unless it's larger than the invoice amount
    [real_paid_amount, invoice.amount].min
  end

  # The total amount a customer paid that was put towards the invoice in Retalix.
  def real_paid_amount
    purged_records.select { |pr| pr.invoice_type == 2 }.map(&:amount).sum
  end

  # Returns the invoice profit dollars, adjusted down by the fraction paid.
  def profit
    invoice.profit * paid_fraction
  end

  # Returns the fraction of the invoice total that was paid (will be < 1 for
  # adjusted invoices).
  def paid_fraction
    return 0 if invoice.amount.zero?
    paid_amount / invoice.amount
  end

  def adjusted_cost
    paid_fraction * invoice.cost
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

  def paid_date
    purged_records.map(&:created_date).max
  end

  private

  def pretty_num(bigdec)
    "%.2f" % bigdec.to_f
  end

  def pretty_bool(bool)
    bool ? "yes" : "no"
  end
end
