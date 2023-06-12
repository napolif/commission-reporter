require 'optparse'

MODELS = %w[customers invoice_headers purged_records]

# :reek:FeatureEnvy
def validate(options)
  unless options[:models] && options[:models].intersection(MODELS).any?
    abort "Exiting; no valid models supplied. Must be in: #{MODELS}."
  end
end

# :reek:UtilityFunction
def log(msg)
  Rails.logger.info(msg)
end

# :reek:FeatureEnvy
# :reek:NestedIterators
# :reek:TooManyStatements
def parse_cli_args
  result = {}

  OptionParser.new do |parser|
    parser.banner = "Usage:"

    parser.on("--models X,Y,Z", Array, "Models to import (comma-separated)") do |val|
      result[:models] = val
    end

    parser.on("--start DATE", "Start date (yyyymmdd) (default: one day after max created_date)") do |val|
      result[:start_date] = Date.from_retalix(val)
    end

    parser.on("--end DATE", "End date (yyyymmdd) (default: one day after max created_date)") do |val|
      result[:end_date] = Date.from_retalix(val)
    end

    parser.on("--fetch-only", "Fetch only (create CSV but don't import)") do |val|
      result[:fetch_only] = true
    end

    parser.on("-h", "--help", "Prints this help") do
      puts parser
      exit
    end
  end.parse!

  result
end

# :reek:UtilityFunction
def fetch(options)
  exporter = RetalixCSVExporter.new

  if options[:models].include?("customers")
    Rails.logger.info "--- creating customer csv ---"
    exporter.export_customers(filename: "import/ffdcstbp.csv")
  end

  if options[:models].include?("invoice_headers")
    Rails.logger.info "--- creating invoice header csv ---"
    exporter.export_invoices(filename: "import/hhhordhp.csv",
                             start_date: InvoiceHeader.max_created_date + 1,
                             end_date: Time.zone.yesterday)
  end

  if options[:models].include?("purged_records")
    Rails.logger.info "--- creating purged record csv ---"
    exporter.export_purged_records(filename: "import/rrwrecwp.csv",
                                   start_date: PurgedRecord.max_created_date + 1,
                                   end_date: Time.zone.yesterday)
  end
end

# :reek:UtilityFunction
def import(options)
  dates = options.slice(:start_date, :end_date)

  if options[:models].include?("customers")
    CustomerImporter.new.run
  end

  if options[:models].include?("invoice_headers")
    InvoiceHeaderImporter.new(**dates).run
  end

  if options[:models].include?("purged_records")
    PurgedRecordImporter.new(**dates).run
  end
end

def main
  opts = parse_cli_args
  log "options: #{opts}"
  validate opts

  if opts[:fetch_only]
    fetch opts
  else
    import opts
  end
end

main
