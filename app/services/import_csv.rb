# An abstract service for uploading a CSV file.
# The target model class should include the Importable concern.
class ImportCSV
  attr_reader :file, :csv, :errors, :result, :records

  class << self
    def target_class(val)
      @target_class = val
    end

    def upsert(val)
      @upsert = val
    end

    def field_map(**val)
      @field_map = val
    end

    def index_field(**val)
      @index_field = val
    end

    def csv_options(**val)
      @csv_options = val
    end
  end

  %i[target_class field_map index_field csv_options upsert].each do |name|
    define_method(name) do
      self.class.instance_variable_get("@#{name}")
    end
  end

  def initialize(file)
    @errors = []
    @result = nil
    @file = file

    options = {headers: true}.merge(csv_options || {})
    @csv = CSV.read(@file, **options)

    validate_headers
  end

  def run
    return false unless valid?
    generate_records
    return false unless valid?

    if upsert
      @result = upsert_records
    else
      @result = insert_records
    end

    true
  end

  def run!
    raise "invalid" unless run
  end

  def valid?
    errors.empty?
  end

  def invalid?
    !valid?
  end

  private

  def validate_headers
    headers = field_map.values
    return if headers.to_set.subset?(csv.headers.to_set)

    errors << "invalid headers (expecting #{headers.join(', ')})"
  end

  def generate_records # rubocop:disable Metrics/AbcSize
    @records = csv.each_with_object([]).with_index do |(row, arr), i|
      rec = initialize_record(row)
      if rec.invalid?
        messages = rec.errors.full_messages.join(",")
        errors << "invalid data in row #{i + 2}: #{messages}"
      else
        arr << rec
      end
    rescue StandardError => e
      errors << "error on row #{i + 2}: #{e}"
    end
  end

  def initialize_record(row)
    target_class.new.tap do |rec|
      field_map.each do |attr, csv_attr|
        transformer = "transform_field_#{attr}"
        raw = row.get(csv_attr)
        val = respond_to?(transformer, true) ? send(transformer, raw) : raw
        rec[attr] = val
        rec.importing = true
      end
    end
  end

  def insert_records
    target_class.import(records, validate: false, all_or_none: true)
  end

  def upsert_records
    target_class.import(
      records,
      validate: false,
      all_or_none: true,
      on_duplicate_key_update: {
        conflict_target: [index_field.keys.first],
        columns: target_class.column_names.without("id", "updated_at")
      }
    )
  end
end
