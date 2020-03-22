# Can generate a CSV containing data from a given set of Commissions.
class CommissionsCSV
  HEADERS = [
    "Inv Num",
    "Cust ID",
    "Cust Name",
    "Invoiced On",
    "Closed On",
    "Age Category",
    "Invoice Total",
    "Invoice Cost",
    "Received $",
    "Applied $",
    "Applied %",
    "Margin %",
    "Cases",
    "Rep Code",
    "Rep Name",
    "Quota Type",
    "Comm Amt"
  ].freeze

  attr_reader :commissions

  def initialize(commissions)
    @commissions = commissions
  end

  def generate
    CSV.generate(write_headers: true, headers: HEADERS) do |csv|
      commissions.each do |comm|
        csv << row(comm).map { |v| format_value(v) }
      end
    end
  end

  private

  def format_value(val)
    return format("%.2f", val.to_f) if val.is_a? BigDecimal
    return "yes" if val.is_a? TrueClass
    return "no" if val.is_a? FalseClass

    val
  end

  # Returns the commission information as an array for use with CSV export.
  def row(comm) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    inv = comm.invoice
    rep = comm.sales_rep

    [
      inv.number,
      inv.customer_code,
      inv.customer.name,
      comm.order_date,
      comm.paid_date,
      comm.age_category,
      inv.amount,
      inv.cost,
      comm.received,
      comm.applied,
      comm.paid_ratio * 100,
      inv.margin_pct,
      inv.qty_ord,
      rep.code,
      rep.name,
      rep.quota_type,
      comm.amount
    ]
  end
end
