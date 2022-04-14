# A service for uploading a CSV file with invoice headers (from alpha).
class ImportAlphaInvoiceHeadersCSV < ImportCSV
  extend Memoist

  target_class InvoiceHeader

  field_map number:        "inv_number",
            rep_code:      "sales_rep",
            customer_code: "cust_code",
            amount:        "amount",
            cost:          "cost",
            order_date:    "maybe_invoice_date",
            qty_ord:       "total_cases"

  natural_keys [:number]

  upsert true

  csv_options col_sep: "\t",
              liberal_parsing: true

  def transform_field_order_date(val)
    Date.strptime(val, "%m/%d/%y") rescue nil
  end

  def transform_field_rep_code(val)
    sales_rep_code_map[val] || val
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

  def sales_rep_code_map
    SalesRep.all.pluck(:alpha_code, :code).each_with_object({}) do |(alf, ret), hsh|
      next unless alf
      hsh[alf] = ret
    end
  end
  memoize :sales_rep_code_map
end
