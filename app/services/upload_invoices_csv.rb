class UploadInvoicesCSV
  attr_reader :file, :csv, :errors, :result, :batch_number

  HEADERS = %w[SLSREPNO CUSTNO CUSTNAME INVNUM LASTORD CRTDATE NETSALES NETCOST REFNUM QRYSHIPPED].freeze
  IGNORED_REPS = %w[550].freeze

  FIELD_MAP = {
    number: "INVNUM",
    sales_rep_code: "SLSREPNO",
    amount: "NETSALES",
    cost: "NETCOST",
    customer_id: "CUSTNO",
    customer_name: "CUSTNAME",
    cases: "QRYSHIPPED"
  }

  def initialize(file)
    @errors = []
    @result = nil
    @file = file
    @csv = CSV.read(@file, headers: true)
    @batch_number = Invoice.next_batch_number + "-csv"
    validate
  end

  def run
    return unless errors.empty?

    invoices = csv.each_with_object([]).with_index do |(row, arr), idx|
      next if row.get("CRTDATE") == "00/00/0000"
      next if row.get("SLSREPNO").in?(IGNORED_REPS)

      begin
        row_num = idx + 2
        inv = invoice_for_row(row)
        if inv.invalid?
          errors << "invalid data in csv row #{row_num}"
        elsif inv.amount.negative?
          errors << "negative sales $ in csv row #{row_num}"
        elsif inv.amount.zero?
          errors << "zero sales $ in csv row #{row_num}"
        else
          arr << inv
        end
      rescue
        errors << "invalid data in csv row #{row_num}"
      end
    end

    return unless errors.empty?

    Invoice.transaction do
      invoices.each(&:save!)
    end

    @result = invoices
    true
  end

  def invoice_for_row(row)
    Invoice.new.tap do |inv|
      FIELD_MAP.each do |attr, hdr|
        inv[attr] = row.get(hdr)
      end

      inv.invoiced_on = Date.strptime(row.get("LASTORD"), "%m/%d/%Y")
      inv.paid_on = Date.strptime(row.get("CRTDATE"), "%m/%d/%Y")
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

  def validate
    unless HEADERS.to_set.subset?(csv.headers.to_set)
      errors << ["invalid headers"]
    end
  end
end
