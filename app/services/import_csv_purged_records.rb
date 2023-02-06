# A service for uploading a CSV file with purged A/R records.
class ImportCSVPurgedRecords < ImportCSV
  extend Memoist

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

  def skip_row?(_row)
    false
  end

  # :reek:TooManyStatements
  def build_record(row)
    target_class.new.tap do |rec|
      rec.importing = true

      field_map.each do |attr, csv_attr|
        val = row.get(csv_attr)

        rec[attr] = case attr
                    when :due_date, :created_date then parse_date(val)
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
      all_or_none: true
    )
  end
end
