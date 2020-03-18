# A service for uploading a CSV file with invoice headers (from alpha).
class ImportAlphaInvoiceHeadersCSV < ImportCSV
  extend Memoist

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
    "BH" => "547"
  }.freeze

  target_class InvoiceHeader

  field_map number:        "inv_number",
            rep_code:      "sales_rep",
            customer_code: "cust_code",
            amount:        "amount",
            cost:          "cost",
            order_date:    "maybe_invoice_date",
            qty_ord:       "total_cases"

  natural_key :number

  upsert true

  csv_options col_sep: "\t",
              liberal_parsing: true

  def transform_field_order_date(val)
    Date.strptime(val, "%m/%d/%y")
  rescue ArgumentError
    nil
  end

  def transform_field_rep_code(val)
    REP_CODE_MAP[val] || val
  end

  def transform_field_customer_code(val)
    customer_code_map[val] || val
  end

  def customer_code_map
    cc_csv = CSV.readlines("../data/customer_mapping.csv", "rb", headers: true)
    cc_csv.each_with_object({}) do |row, hsh|
      key = row.get("ID Alpha").sub(/^'/, "")
      val = row.get("ID Retalix").sub(/^'/, "")
      hsh[key] = val
    end
  end
  memoize :customer_code_map
end
