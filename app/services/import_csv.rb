# An abstract service for uploading a CSV file.
class ImportCSV
  attr_reader :file, :csv, :errors, :result, :records

  def self.target_class(val)
    @@target_class = val
  end

  def self.field_map(**val)
    @@field_map = val
  end

  def self.index_field(**val)
    @@index_field = val
  end

  def initialize(file)
    @errors = []
    @result = nil
    @file = file
    @csv = CSV.read(@file, headers: true)

    validate_headers
  end

  def run
    return false unless valid?
    generate_records
    return false unless valid?

    @result = import_records
    true
  end

  def valid?
    errors.empty?
  end

  def invalid?
    !valid?
  end

  private

  def generate_records
    @records = csv.each_with_object([]).with_index do |(row, arr), i|
      begin
        rec = initialize_record(row)
        if rec.invalid?
          messages = rec.errors.full_messages.join(',')
          errors << "invalid data in row #{i + 2}: #{messages}"
        else
          arr << rec
        end
      rescue StandardError => e
        errors << "error on row #{i + 2}: #{e}"
      end
    end
  end

  def import_records
    @@target_class.import(records, validate: false, all_or_none: true)
  end

  def update_column_names
    @@target_class.column_names.without("id", "updated_at")
  end

  def initialize_record(row)
    @@target_class.new.tap do |rec|
      @@field_map.each do |attr, csv_attr|
        transformer = "transform_field_#{attr}"
        raw = row.get(csv_attr)
        val = respond_to?(transformer, true) ? send(transformer, raw) : raw
        rec[attr] = val
        rec.importing = true
      end
    end
  end

  def validate_headers
    return if headers.to_set.subset?(csv.headers.to_set)

    errors << "invalid headers (expecting #{headers.join(', ')})"
  end

  def headers
    @@field_map.values
  end

  def id_attr
    @@index_field.keys.first
  end

  def csv_id_attr
    @@index_field.values.first
  end
end