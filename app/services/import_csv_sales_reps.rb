# A service for uploading a CSV file with sales reps.
#
# :reek:InstanceVariableAssumption
class ImportCSVSalesReps < ImportCSV
  target_class SalesRep

  field_map code:       "code",
            name:       "name",
            rep_type:   "rep_type",
            disabled:   "disabled",
            quota_type: "quota_type"

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
                    when :basis then map_basis(val)
                    when :team then map_team(val)
                    else val
                    end
      end
    end

    # TODO: store the tiers
  end

  # :reek:ControlParameter
  def map_basis(val)
    case val
    when "revenue" then 1
    else 0
    end
  end

  # :reek:ControlParameter
  def map_team(val)
    case val
    when "outside" then 1
    when "broker" then 2
    else 0 # inside
    end
  end

  # :reek:UtilityFunction
  def store_records(records)
    target_class.import(
      records,
      validate: false,
      all_or_none: true,
      on_duplicate_key_update: {
        conflict_target: [:code],
        columns: target_class.column_names.without("id", "updated_at")
      }
    )
  end
end
