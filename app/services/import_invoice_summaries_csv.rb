# A service for uploading a CSV file. Similar to active_interaction classes.
#
# TODO: either trash this or extend from ImportCSV
class ImportInvoiceSummariesCSV
  attr_reader :file, :csv, :errors, :result, :batch_number, :records

  HEADERS = %w[HHUSLNB HHUCUSN HHUCNMB HHUINVN LDATE RDATE HHUEXSN HHUEXCR HHUINVR HHUQYSA].freeze
  FIELD_MAP = {
    number: "HHUINVN",
    sales_rep_code: "HHUSLNB",
    amount: "HHUEXSN",
    cost: "HHUEXCR",
    customer_code: "HHUCUSN",
    customer_name: "HHUCNMB",
    cases: "HHUQYSA"
  }.freeze

  def initialize(file)
    @errors = []
    @result = nil
    @file = file
    @csv = CSV.read(@file, headers: true)
    validate_headers

    @batch_number = InvoiceSummary.next_batch_number + "-csv"

    numbers = csv.map { |x| x["HHUINVN"].strip }
    @found_invoices = InvoiceSummary.where(number: numbers).index_by(&:number)
  end

  def run!
    raise "invalid" unless run
  end

  def run
    return unless errors.empty?

    @records = csv.each_with_object([]).with_index do |(row, arr), idx|
      # next if row.get("RDATE") == "00/00/0000"

      begin
        row_num = idx + 2
        inv = invoice_for_row(row)
        if inv.invalid?
          errors << "invalid data in row #{row_num}: #{inv.errors.full_messages.join(',')}"
        else
          arr << inv
        end
      rescue StandardError => e
        errors << "invalid data in row #{row_num}: #{e}"
      end
    end

    return unless errors.empty?

    update_columns = InvoiceSummary.column_names.without("id", "updated_at")
    @result = InvoiceSummary.import(@records,
                                    on_duplicate_key_update: update_columns)
    true
  end

  def invoice_for_row(row)
    found = @found_invoices[row.get("HHUINVN")]

    (found || InvoiceSummary.new).tap do |inv|
      FIELD_MAP.each do |attr, hdr|
        inv[attr] = row.get(hdr)
      end

      inv.invoiced_on = Date.strptime(row.get("LDATE"), "%m/%d/%Y")

      begin
        inv.paid_on = Date.strptime(row.get("RDATE"), "%m/%d/%Y")
      rescue
        inv.paid_on = nil
      end

      inv.batch = batch_number
    end
  end

  def valid?
    errors.empty?
  end

  def invalid?
    !valid?
  end

  private

  def validate_headers
    return if HEADERS.to_set.subset?(csv.headers.to_set)

    errors << "invalid headers (expecting #{HEADERS.join(', ')})"
  end
end
