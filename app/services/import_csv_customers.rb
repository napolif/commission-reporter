# A service for uploading a CSV file with customer data.
#
# :reek:InstanceVariableAssumption
class ImportCSVCustomers < ImportCSV
  target_class Customer

  field_map code: "FFDCUSN",
            name: "FFDCNMB"

  # :reek:FeatureEnvy
  def skip_row?(row)
    code = row.get("FFDCUSN")
    code.empty? || @already_seen&.include?(code)
  end

  # :reek:TooManyStatements
  def build_record(row)
    record = target_class.new.tap do |rec|
      rec.importing = true
      rec.location = 6

      field_map.each do |attr, csv_attr|
        rec[attr] = row.get(csv_attr)
      end
    end

    @already_seen ||= Set.new
    @already_seen << record.code
    record
  end

  # :reek:UtilityFunction
  def store_records(records)
    target_class.import(
      records,
      validate: false,
      all_or_none: true,
      on_duplicate_key_update: {
        conflict_target: [:code, :location],
        columns: target_class.column_names.without("id", "updated_at")
      }
    )
  end
end
