# Collected data for rendering ReportsController#show.
class ReportsShowPresenter
  extend Memoist

  attr_reader :batch_num

  CSV_DELIM = ",".freeze

  def initialize(batch_num)
    @batch_num = batch_num
  end

  def as_csv
    head = ["Inv Num", "Cust ID", "Cust Name",
            "Invoiced On", "Paid On", "Age Category",
            "Amount", "Cost", "Margin %", "Cases", "Delivered",
            "SR Code", "SR Name", "SR Quota Type", "Comm Amt"].join(CSV_DELIM)

    body =
      commissions_by_enabled_rep.values.flatten.map do |c|
        i = c.invoice
        s = c.sales_rep
        delivered = if i.delivered then "yes" else "no" end
        margin_pct = "%.2f" % i.margin_pct.to_f
        c_amount = "%.2f" % c.amount.to_f

        [i.number, i.customer_id, i.customer_name,
         i.invoiced_on, i.paid_on, i.age_category,
         i.amount, i.cost, margin_pct, i.cases, delivered,
         s.code, s.name, s.quota_type, c_amount].join(CSV_DELIM)
      end.join("\n")

    [head, body].join("\n")
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
    totals_by_enabled_rep.values.reduce(:+)
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

  def invoices
    if batch_num == "latest"
      Invoice.latest_batch
    else
      Invoice.where(batch: batch_num)
    end.includes(:sales_rep)
  end
  memoize :invoices
end
