# A service for uploading a CSV file with customer data.
class ImportCustomersCSV < ImportCSV
  target_class Customer

  field_map code: "FFDCUSN",
            name: "FFDCNMB",
            location: "FFDDIVN"

  natural_keys [:location, :code]

  upsert true

  def skip_row?(row)
    # skip unless company 1 (not sure what company 2 is for but it has duplicates)
    return true unless row.get("FFDCMPN") == "1"

    # skip if name is blank
    return true if row.get("FFDCNMB").empty?

    # skip records ending in space, which tend to be duplicates & junk records
    return true if row["FFDCUSN"].end_with? " "
  end
end
