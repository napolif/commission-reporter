# A service for uploading a CSV file with invoice headers (from retalix).
class ImportInvoiceHeadersCSV < ImportCSV
  target_class InvoiceHeader

  field_map number:        "HHHINVN",
            rep_code:      "HHHSLNB",
            customer_code: "HHHCUSN",
            amount:        "HHHEXSN",
            cost:          "HHHEXRC",
            order_date:    "HHHDTET",
            qty_ord:       "HHHQYOA"

  natural_key :number

  upsert true

  def transform_field_order_date(val)
    Date.strptime(val, "%Y%m%d")
  rescue ArgumentError
    nil
  end
end
