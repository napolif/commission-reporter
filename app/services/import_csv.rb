# An abstract service for uploading a CSV file.
# The target model class should include the Importable concern.
class ImportCSV
  attr_reader :file, :csv, :errors, :result, :records

  # rubocop:disable Style/TrivialAccessors
  class << self
    def target_class(val)
      @target_class = val
    end

    def upsert(val)
      @upsert = val
    end

    def natural_keys(val)
      @natural_keys = val
    end

    def field_map(**val)
      @field_map = val
    end

    def csv_options(**val)
      @csv_options = val
    end
  end
  # rubocop:enable Style/TrivialAccessors

  %i[target_class field_map natural_keys csv_options upsert].each do |name|
    define_method(name) do
      self.class.instance_variable_get("@#{name}")
    end
  end

  def initialize(file)
    @errors = []
    @result = nil
    @file = file

    options = {headers: true, encoding: 'ISO-8859-1'}.merge(csv_options || {})
    @csv = CSV.read(@file, **options)

    validate_headers
  end

  def run
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil

    unless valid?
      ActiveRecord::Base.logger = old_logger
      return false
    end

    generate_records

    unless valid?
      ActiveRecord::Base.logger = old_logger
      return false
    end

    @result = if upsert
                upsert_records
              else
                insert_records
              end

    ActiveRecord::Base.logger = old_logger
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
      next if skip_row?(row)

      if rec.invalid?
        messages = rec.errors.full_messages.join(",")
        errors << "invalid data in row #{i}: #{messages}"
      else
        arr << rec
      end
    rescue StandardError => e
      errors << "error on row #{i}: #{e}"
    end
  end

  def skip_row?(_row)
    false
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
        conflict_target: natural_keys,
        columns: target_class.column_names.without("id", "updated_at")
      }
    )
  end
end
