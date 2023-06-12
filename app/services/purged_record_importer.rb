# Imports PurgedRecords from Retalix, storing the query result as a temporary CSV
# file as an intermediate step.
#
# We can't upsert PurgedRecords because they don't have a unique identifier in Retalix.
# So by default we import everything after the current max created_date (and only
# import up to yesterday, so that we never get part of a day.)
class PurgedRecordImporter
  def initialize(start_date: PurgedRecord.max_created_date + 1,
                 end_date: Time.zone.yesterday)
    @start_date = start_date
    @end_date = end_date
    @filename = Tempfile.new(%w[purged_records .csv]).path
  end

  def run
    Rails.logger.info "--- importing account entries ---"
    return unless validate_dates
    return unless ensure_no_duplicates
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

  def ensure_no_duplicates
    if PurgedRecord.where(created_date: @start_date..@end_date).any?
      Rails.logger.error "import failed: account entries already exist in this date range"
      return false
    end

    true
  end

  def export_csv_from_retalix
    RetalixCSVExporter.new.export_purged_records(filename: @filename,
                                                 start_date: @start_date,
                                                 end_date: @end_date)
  end

  def import_csv
    File.open(@filename, encoding: "ibm437:utf-8") do |file|
      ImportCSVPurgedRecords.new(file).run
    end
  end
end
