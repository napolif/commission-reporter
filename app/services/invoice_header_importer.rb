# Imports InvoiceHeaders from Retalix, storing the query result as a temporary CSV
# file as an intermediate step.
#
# Inovices can be upserted, however, the same logic that works for account entries
# should work here as well.
class InvoiceHeaderImporter
  def initialize(start_date: InvoiceHeader.max_created_date + 1,
                 end_date: Time.zone.yesterday)
    @start_date = start_date
    @end_date = end_date
    @filename = Tempfile.new(%w[invoices .csv]).path
  end

  def run
    Rails.logger.info "--- importing invoices ---"
    return unless validate_dates
    export_csv_from_retalix
    import_csv
  end

  private

  def validate_dates
    if @start_date > @end_date
      Rails.logger.error "import failed: start_date is later than end_date"
      return false
    end

    true
  end

  def export_csv_from_retalix
    RetalixCSVExporter.new.export_invoices(filename: @filename,
                                           start_date: @start_date,
                                           end_date: @end_date)
  end

  def import_csv
    File.open(@filename, encoding: "ibm437:utf-8") do |file|
      ImportCSVInvoiceHeaders.new(file).run
    end
  end
end
