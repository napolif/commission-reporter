require "csv"
require "odbc"

# Fetches data from Retalix.
class RetalixCSVExporter
  def initialize
    @records = nil
    @column_names = nil
  end

  def export_customers(filename:)
    export(<<~SQL, filename)
      select
        FFDCMPN, FFDDIVN, FFDDPTN, FFDARCD,
        FFDCUSN, FFDCNMB, FFDSLNB
      from FFDCSTBP
      where FFDCMPN = '  1'
    SQL
  end

  def export_sales_reps(filename:)
    export(<<~SQL, filename)
      select * from FFRSLSAP
    SQL
  end

  def export_invoices(filename:, start_date:, end_date:)
    header_columns = <<~SQL.chomp
      HHHCMPN, HHHDIVN, HHHDPTN, HHHCUSN, HHHSLNB, HHHDTET,
      HHHINVN, HHHQYOA, HHHEXSN, HHHEXRC, HHHCDTE, HHHEXCG,
      HHHEXTF, HHHEXIA, HHHEXBW
    SQL

    export(<<~SQL, filename)
      select #{header_columns}
      from HHHORDHP
      where HHHCDTE >= #{start_date.retalix}
      and HHHCDTE <= #{end_date.retalix}
    SQL
  end

  def export_account_entries(filename:, start_date:, end_date:)
    export(<<~SQL, filename)
      select
        RRWCMPN, RRWDIVN, RRWDPTN, RRWJCDE, RRWCUSN, RRWINVN,
        RRWINAM, RRWSLNB, RRWDTED, RRWDTRA, RRWINVR, RRWRTPE
      from RRWRECWP
      where RRWDTRA >= #{start_date.retalix}
      and RRWDTRA <= #{end_date.retalix}
    SQL
  end

  private

  # :reek:UtilityFunction
  def log(message)
    Rails.logger.info message
  end

  # :reek:TooManyStatements
  # :reek:NestedIterators
  def export(query, filename)
    log "Query:\n#{query.chomp}"

    log "Connecting..."
    ODBC.connect("retalix") do |db|
      run_query(db, query) do |stmt|
        @column_names = stmt.columns.keys
        @records = stmt.fetch_all
      end
    end

    log "Writing #{filename}"
    CSV.open(filename, "wb", write_headers: true, headers: @column_names) do |csv|
      if @records
        @records.each do |rec|
          csv << rec
        end
      else
        log "no records."
      end
    end

    log "...done."
  end

  # :reek:UtilityFunction
  def run_query(db, query)
    statement = db.run query
    yield statement
    statement.drop
  end
end
