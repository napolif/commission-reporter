# A service for uploading a CSV file with invoice headers (from retalix).
class ImportCSVInvoiceHeaders < ImportCSV
  extend Memoist

  target_class InvoiceHeader

  field_map number:        "HHHINVN",
            rep_code:      "HHHSLNB",
            customer_code: "HHHCUSN",
            amount:        "HHHEXSN",
            cost:          "HHHEXRC",
            order_date:    "HHHDTET",
            created_date:  "HHHCDTE",
            qty_ord:       "HHHQYOA"

  def skip_row?(row)
    !parse_date(row.get("HHHDTET"))
  end

  # :reek:TooManyStatements
  def build_record(row)
    target_class.new.tap do |rec|
      rec.importing = true

      field_map.each do |attr, csv_attr|
        val = row.get(csv_attr)
        rec[attr] = case attr
                    when :order_date then parse_date(val)
                    else val
                    end
      end
    end
  end

  # :reek:UtilityFunction
  def parse_date(val)
    Date.strptime(val, "%Y%m%d") rescue nil
  end
  memoize :parse_date

  # :reek:UtilityFunction
  def store_records(records)
    target_class.import(
      records,
      validate: false,
      all_or_none: true,
      on_duplicate_key_update: {
        conflict_target: [:number],
        columns: target_class.column_names.without("id", "updated_at")
      }
    )
  end
end
