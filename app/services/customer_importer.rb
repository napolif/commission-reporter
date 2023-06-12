# Imports Customers from Retalix, storing the query result as a temporary CSV
# file as an intermediate step.
#
# All reps are fetched every time, and the result is upserted.
class CustomerImporter
  def initialize
    @filename = Tempfile.new(%w[customers .csv]).path
  end

  def run
    Rails.logger.info "--- importing customers ---"
    export_csv_from_retalix
    import_csv
  end

  private

  def export_csv_from_retalix
    RetalixCSVExporter.new.export_customers(filename: @filename)
  end

  def import_csv
    File.open(@filename, encoding: "ibm437:utf-8") do |file|
      ImportCSVCustomers.new(file).run
    end
  end
end
