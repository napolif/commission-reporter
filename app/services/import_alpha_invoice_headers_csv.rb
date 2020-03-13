# A service for uploading a CSV file with invoice headers (from alpha).
class ImportAlphaInvoiceHeadersCSV < ImportCSV
  target_class InvoiceHeader

  field_map number:         "inv_number",
            rep_code:       "sales_rep",
            customer_code:  "cust_code",
            amount:         "amount",
            cost:           "cost",
            order_date:     "maybe_invoice_date",
            qty_ord:        "total_cases"

  index_field number: "inv_number"

  def initialize(file)
    super(file, col_sep: "\t", liberal_parsing: true)
  end

  def import_records
    update_columns = @@target_class.column_names.without("id", "updated_at")
    @@target_class.import(
      records,
      validate_uniqueness: false,
      validate: false,
      all_or_none: true,
      on_duplicate_key_update: {
        conflict_target: [:number],
        columns: update_columns
      }
    )
  end

  def transform_field_order_date(val)
    Date.strptime(val, "%m/%d/%y")
  rescue
    nil
  end
end
