# A service for uploading a CSV file with customer data.
class ImportCustomersCSV < ImportCSV
  target_class Customer

  field_map code: "FFDCUSN",
            name: "FFDCNMB"

  natural_key :code

  upsert true

  def skip_row?(row)
    row.get("FFDCMPN") != "1" || row.get("FFDDIVN") != "6" || row.get("FFDDPTN") != "6"
  end
end
