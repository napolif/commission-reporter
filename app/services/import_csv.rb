require "csv"

# Abstract base class for importing a CSV file. These will need to be called in the
# subclass to supply a value: ::target_class, ::field_map
#
# These should be overwritten: #skip_row?, #build_record, #store_records
#
# :reek:TooManyInstanceVariables
# :reek:TooManyMethods
# :reek:InstanceVariableAssumption
class ImportCSV
  extend Memoist

  attr_reader :csv, :results, :errors

  # DSL-style setters meant to be called in the subclass. Values are stored
  # on the class instance.
  class << self
    def target_class(val)
      @target_class = val
    end

    def field_map(**val)
      @field_map = val
    end
  end

  def target_class
    self.class.instance_variable_get("@target_class")
  end

  def field_map
    self.class.instance_variable_get("@field_map")
  end

  # --------------------------------------------------------------------------

  # Build a new ImportCSV service.
  #
  # Chunk size controls how many csv rows are imported at a time. Higher numbers
  # mean more memory use but fewer database trips.
  #
  # All inserts happen in a single transaction.
  def initialize(file, logger: nil, chunk_size: 10000)
    @file = file
    @logger = logger
    @errors = []
    @csv = CSV.new(file, headers: :first_row, return_headers: true)
    @results = []
    @chunk_size = chunk_size

    log "File path: #{File.realpath(@file.path)}"
    log "Row count: #{line_count - 1}"
  end

  # Runs the service. Returns true if there were no errors, false if there were.
  def run
    validate_headers

    if valid?
      log_db_counts do
        target_class.transaction { process_rows }
      end
    end

    log "errors: #{@errors}"
    valid?
  end

  # Returns true if there were no errors.
  def valid?
    @errors.empty?
  end

  private

  def validate_headers
    headers = field_map.values.to_set
    csv_headers = @csv.shift.to_a.transpose.first.to_set
    return if csv_headers.superset?(headers)
    @errors << "invalid headers (expecting #{headers.join(', ')})"
  end

  # :reek:TooManyStatements
  # :reek:DuplicateMethodCall
  def process_rows # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    idx = 0

    catch :done do
      loop do
        @chunk = []
        log progress_message(idx)

        @chunk_size.times do
          row = @csv.shift
          unless row
            @results << store_records_silent(@chunk) # store the last few
            log "done.\n"
            throw :done
          end

          next if skip_row?(row)

          record = build_record(row)
          if record.invalid?
            add_error(record, row, idx)
            next
          end

          @chunk << record
          idx += 1
        end
        @results << store_records_silent(@chunk)
      end
    end
  end

  def add_error(record, row, index)
    messages = record.errors.full_messages.join(",")
    @errors << "invalid data in row #{index}: #{messages}. contents: #{row}"
  end

  def log(message)
    @logger&.info(message)
  end

  def line_count
    File.foreach(@file.path).reduce(0) { |count, _line| count + 1 }
  end
  memoize :line_count

  def progress_message(row_count)
    progress = 100 * row_count / line_count.to_f
    "reading row #{row_count} (#{progress.to_i}%)"
  end

  # :reek:DuplicateMethodCall
  def log_db_counts
    log "#{target_class} start count: #{target_class.count}"
    yield
    log "#{target_class} end count: #{target_class.count}"
  end

  def store_records_silent(records)
    ActiveRecord::Base.logger.silence do
      return store_records(records)
    end
  end

  def skip_row?(_row)
    raise "you're supposed to override me"
  end

  def build_record(_row)
    raise "you're supposed to override me"
  end

  def store_records(_records)
    raise "you're supposed to override me"
  end
end
