# A service for uploading a CSV file with purged A/R records.
class ImportPurgedRecordsCSV < ImportCSV
  target_class PurgedRecord

  field_map invoice_number: "RRWINVN",
            amount:         "RRWINAM",
            customer_code:  "RRWCUSN",
            rep_code:       "RRWSLNB",
            due_date:       "RRWDTED",
            created_date:   "RRWDTRA",
            adj_code:       "RRWJCDE",
            ref_number:     "RRWINVR",
            invoice_type:   "RRWRTPE"

  natural_key number: "RRWINVN"

  upsert false

  def transform_field_due_date(val)
    Date.strptime(val, "%Y%m%d")
  rescue ArgumentError
    nil
  end

  def transform_field_created_date(val)
    Date.strptime(val, "%Y%m%d")
  rescue ArgumentError
    nil
  end

  def transform_field_ref_number(val)
    val == "0" ? nil : val
  end
end
