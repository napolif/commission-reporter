# Collected data for rendering ReportsController#show.
class ReportsShowPresenter
  extend Memoist

  attr_reader :batch_num
  attr_reader :invoices

  def initialize(invoices)
    @invoices = invoices
  end

  def as_csv
    headers = ["Inv Num", "Cust ID", "Cust Name", "Invoiced On", "Paid On",
               "Age Category", "Amount", "Cost", "Margin %", "Cases",
               "Delivered", "SR Code", "SR Name", "SR Quota Type", "Comm Amt"]

    CSV.generate(col_sep: ",", write_headers: true, headers: headers) do |csv|
      commissions_by_enabled_rep.values.flatten.each do |comm|
        csv << csv_row(comm)
      end
    end
  end

  def commissions_by_enabled_rep
    enabled_rep_codes.each_with_object({}) do |code, hash|
      key = reps_by_code[code]
      value = commissions_by_code[code]
      hash[key] = value
    end
  end

  def total_rows
    rows = totals_by_enabled_rep.to_a
    rows.sort_by { |row| row.first.code }.sort_by(&:second).reverse
  end

  def grand_total
    totals_by_enabled_rep.values.reduce(:+) || 0
  end

  def disabled_reps
    disabled_rep_codes.map do |code|
      reps_by_code[code]
    end
  end

  private

  def enabled_rep_codes
    rep_codes.reject do |code|
      reps_by_code[code]&.disabled
    end
  end

  def disabled_rep_codes
    rep_codes.filter do |code|
      reps_by_code[code]&.disabled
    end
  end

  def commissions_by_code
    invoices_by_code.transform_values do |invs|
      invs.map { |inv| Commission.new(inv) }
    end
  end
  memoize :commissions_by_code

  def totals_by_enabled_rep
    commissions_by_enabled_rep.transform_values do |comms|
      comms.map(&:amount).reduce(:+)
    end
  end
  memoize :totals_by_enabled_rep

  def reps_by_code
    known_reps_by_code = SalesRep.all.index_by(&:code)

    rep_codes.each_with_object({}) do |code, hash|
      hash[code] = known_reps_by_code[code] || SalesRep.default_new(code)
    end
  end
  memoize :reps_by_code

  def rep_codes
    invoices_by_code.keys.sort
  end
  memoize :rep_codes

  def invoices_by_code
    invoices.group_by(&:sales_rep_code)
  end
  memoize :invoices_by_code

  def csv_row(commission)
    inv = commission.invoice
    rep = commission.sales_rep

    [
      inv.number, inv.customer_code, inv.customer_name, inv.invoiced_on,
      inv.paid_on, inv.age_category, inv.amount, inv.cost,
      pretty_num(inv.margin_pct), inv.cases, pretty_bool(inv.delivered),
      rep.code, rep.name, rep.quota_type, pretty_num(commission.amount)
    ]
  end

  def pretty_num(bigdec)
    "%.2f" % bigdec.to_f
  end

  def pretty_bool(bool)
    bool ? "yes" : "no"
  end
end
