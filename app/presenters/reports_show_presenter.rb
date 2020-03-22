# Collected data for rendering ReportsController#show.
class ReportsShowPresenter
  extend Memoist

  attr_reader :batch_num
  attr_reader :purged_records

  def initialize(purged_records)
    @purged_records = purged_records
  end

  def as_csv
    headers = ["Inv Num", "Cust ID", "Cust Name", "Invoiced On", "Closed On",
               "Age Category",
               "Invoice Total",
               "Invoice Cost",
               "Received $",
               "Applied $",
               "Applied %",
               "Margin %",
               "Cases", "Rep Code", "Rep Name",
               "Quota Type", "Comm Amt"]

    CSV.generate(write_headers: true, headers: headers) do |csv|
      commissions_by_enabled_rep.values.flatten.each do |comm|
        csv << comm.as_csv
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
    rows.sort_by { |row| row.first.code }
  end

  def grand_total
    totals_by_enabled_rep.values.sum
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
    purged_records_by_code.transform_values do |prs|
      invoice_groups = prs.group_by(&:invoice_number)
      comms = invoice_groups.map do |_num, iprs|
        Commission.new(iprs)
      end
      comms.reject { |c| c.amount.zero? }.sort_by(&:number)
    end
  end
  memoize :commissions_by_code

  def totals_by_enabled_rep
    commissions_by_enabled_rep.transform_values do |comms|
      comms.map(&:amount).sum
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
    purged_records_by_code.keys.sort
  end
  memoize :rep_codes

  def purged_records_by_code
    purged_records.group_by { |pr| pr.invoice_header.rep_code }
  end
  memoize :purged_records_by_code
end
