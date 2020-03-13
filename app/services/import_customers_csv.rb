# A service for uploading a CSV file with customer data.
class ImportCustomersCSV < ImportCSV
  target_class Customer

  field_map code: "FFDCUSN",
            name: "FFDCNMB"

  index_field code: "FFDCUSN"

  def import_records
    update_columns = @@target_class.column_names.without("id", "updated_at")
    @@target_class.import(
      records,
      validate_uniqueness: false,
      validate: false,
      all_or_none: true,
      on_duplicate_key_update: {
        conflict_target: [:code],
        columns: update_columns
      }
    )
  end
end
