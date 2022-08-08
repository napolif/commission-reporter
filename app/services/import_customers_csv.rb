# A service for uploading a CSV file with customer data.
class ImportCustomersCSV < ImportCSV
  target_class Customer

  field_map code: "FFDCUSN",
            name: "FFDCNMB",
            location: "FFDDIVN"

  natural_keys [:location, :code]

  upsert true

  def skip_row?(row)
    return true if row["FFDCNMB"].blank?

    # skip bad records, e.g. "ILLIAN " which are likely to be duplicates
    return true if row["FFDCUSN"].end_with? " "

    row.get("FFDDIVN") != "6"
  end
end
