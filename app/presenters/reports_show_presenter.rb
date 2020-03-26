# Collected data for rendering ReportsController#show.
class ReportsShowPresenter
  extend Memoist

  attr_reader :batch_num
  attr_reader :purged_records
  attr_reader :rep_codes

  def initialize(purged_records:, rep_codes:)
    @purged_records = purged_records
    @rep_codes = rep_codes.sort
  end

  def commissions_by_enabled_rep
    enabled_rep_codes.each_with_object({}) do |code, hash|
      key = reps_by_code[code]
      value = commissions_by_code[code] || []
      hash[key] = value
    end
  end

  def total_rows
    reps = total_amounts_by_enabled_rep.keys.sort_by(&:code)

    reps.each_with_object([]) do |rep, arr|
      arr << [
        rep,
        total_applied_by_enabled_rep[rep],
        total_sales_by_enabled_rep[rep],
        margin_pcts_by_enabled_rep[rep],
        total_amounts_by_enabled_rep[rep]
      ]
    end
  end

  def grand_total
    total_amounts_by_enabled_rep.values.sum
  end

  def grand_margin_pct
    overall_margin_pct(commissions)
  end

  def disabled_reps
    disabled_rep_codes.map do |code|
      reps_by_code[code]
    end
  end

  def commissions
    commissions_by_enabled_rep.values.flatten
  end
  memoize :commissions

  def margin_pcts_by_enabled_rep
    commissions_by_enabled_rep.transform_values do |comms|
      overall_margin_pct(comms)
    end
  end
  memoize :margin_pcts_by_enabled_rep

  def total_amounts_by_enabled_rep
    commissions_by_enabled_rep.transform_values do |comms|
      comms.select(&:normal?).map(&:amount).sum
    end
  end
  memoize :total_amounts_by_enabled_rep

  private

  def total_sales_by_enabled_rep
    commissions_by_enabled_rep.transform_values do |comms|
      comms.select(&:normal?).map { |c| c.invoice.amount }.sum
    end
  end
  memoize :total_sales_by_enabled_rep

  def total_applied_by_enabled_rep
    commissions_by_enabled_rep.transform_values do |comms|
      comms.select(&:normal?).map(&:applied).sum
    end
  end
  memoize :total_applied_by_enabled_rep

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
      comms.sort_by(&:number)
    end
  end
  memoize :commissions_by_code

  def reps_by_code
    known_reps_by_code = SalesRep.all.index_by(&:code)

    rep_codes.each_with_object({}) do |code, hash|
      hash[code] = known_reps_by_code[code] || SalesRep.default_new(code)
    end
  end
  memoize :reps_by_code

  def purged_records_by_code
    purged_records.group_by { |pr| pr.invoice_header.rep_code }
  end
  memoize :purged_records_by_code

  def overall_margin_pct(comms)
    comms = comms.select(&:normal?)
    tsales = comms.map { |c| c.invoice.amount }.sum
    return 0 if tsales.zero?

    tcosts = comms.map { |c| c.invoice.cost }.sum
    100 * (tsales - tcosts) / tsales
  end
end
