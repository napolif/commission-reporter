# A service for uploading a CSV file with invoice headers (from retalix).
class ImportInvoiceHeadersCSV < ImportCSV
  target_class InvoiceHeader

  field_map number:         "HHHINVN",
            rep_code:       "HHHSLNB",
            customer_code:  "HHHCUSN",
            amount:         "HHHINAM",
            cost:           "HHHEXCR",
            order_date:     "HHHDTET",
            qty_ord:        "HHHQYOA"

  index_field number: "HHHINVN"

  def transform_field_order_date(val)
    Date.strptime(val, "%Y%m%d")
  rescue
    nil
  end

  def import_records
    @@target_class.import(records, validate_uniqueness: false, validate: false, all_or_none: true)
  end
end
