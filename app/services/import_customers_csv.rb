# A service for uploading a CSV file with customer data.
class ImportCustomersCSV < ImportCSV
  target_class Customer

  field_map code: "FFDCUSN",
            name: "FFDCNMB",
            location: "FFDDIVN"

  natural_keys [:code]

  upsert true

  def skip_row?(row)
    # skip if name is blank
    return true if row["FFDCNMB"].blank?

    # skip bad records, e.g. "ILLIAN " which are likely to be duplicates
    return true if row["FFDCUSN"].end_with? " "

    # skip unless company 1 (not sure what company 2 is for but it has duplicates)
    return true if row.get("FFDCMPN") != "1"

    # skip unless division 6 / CT
    row.get("FFDDIVN") != "6"
  end
end
