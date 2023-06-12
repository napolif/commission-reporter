namespace :retalix do
  desc "Imports data from Retalix."
  task import: :environment do
    CustomerImporter.new.run
    InvoiceHeaderImporter.new.run
    PurgedRecordImporter.new.run
  end

  desc "Fetches data from Retalix & stores as CSV files."
  task fetch: :environment do
    RetalixCSVExporter.new.tap do |e|
      e.export_customers(filename: "import/ffdcstbp.csv")
      e.export_invoice_headers(filename: "import/hhhordhp.csv",
                               start_date: InvoiceHeader.max_created_date + 1,
                               end_date: Time.zone.yesterday)
      e.export_purged_records(filename: "import/rrwrecwp.csv",
                              start_date: PurgedRecord.max_created_date + 1,
                              end_date: Time.zone.yesterday)
    end
  end
end
