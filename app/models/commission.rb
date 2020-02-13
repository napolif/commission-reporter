class Commission
  attr_reader :paid_invoice, :sales_rep

  delegate :age_category, to: :paid_invoice
  delegate :margin_pct, to: :paid_invoice
  delegate :commission_table, to: :sales_rep
  delegate :comm_type, to: :sales_rep

  def initialize(paid_invoice)
    @paid_invoice = paid_invoice
    @sales_rep = paid_invoice.sales_rep
  end

  # Returns the commission for the associated invoice in dollars.
  def amount
    adjusted = adjusted_pct / 100

    if sales_rep.comm_type == "S"
      adjusted * paid_invoice.amount
    else
      adjusted * paid_invoice.profit
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
    commission_table.reverse.find do |i, goal, comm|
      margin_pct >= goal
    end
  end

  # Returns the commission adjustment given the invoice payment age.
  def age_adjustment_pct
    period = SalesRep::PERIODS_BY_AGE[age_category]
    sales_rep[period]
  end
end
