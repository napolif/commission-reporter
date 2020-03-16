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

  REP_CODE_MAP = {
    "PH" => "417",
    "CP" => "501",
    "FF" => "502",
    "CK" => "503",
    "RC" => "504",
    "JB" => "507",
    "JF" => "508",
    "LC" => "509",
    "MM" => "510",
    "MP" => "511",
    "NS" => "512",
    "PN" => "515",
    "OF" => "516",
    "JE" => "517",
    "AC" => "518",
    "RD" => "519",
    "SS" => "520",
    "GP" => "521",
    "TS" => "527",
    "JC" => "528",
    "SD" => "529",
    "BB" => "530",
    "RA" => "531",
    "KC" => "532",
    "MC" => "533",
    "AG" => "534",
    "CG" => "535",
    "RP" => "537",
    "WD" => "538",
    "JK" => "545",
    "DC" => "546",
    "AM" => "548",
    "AF" => "549",
    "NF" => "550",
    "FT" => "552",
    "BH" => "547",
  }.freeze

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

  def transform_field_rep_code(val)
    REP_CODE_MAP[val] || val
  end
end
