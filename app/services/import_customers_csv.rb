# A service for uploading a CSV file with customer data.
class ImportCustomersCSV < ImportCSV
  target_class Customer

  field_map code: "FFDCUSN",
            name: "FFDCNMB",
            location: "FFDDIVN"

  natural_keys [:location, :code]

  upsert true

  LOCATIONS = [
    "2", # NJ
    "6"  # CT
  ].freeze

  def skip_row?(row)
    # skip bad records, e.g. "ILLIAN " which are likely to be duplicates
    return true if row["FFDCUSN"].end_with? " "

    LOCATIONS.exclude? row.get("FFDDIVN")
  end
end
