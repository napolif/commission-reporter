# import retalix invoice headers

def print_counts(model_class)
  puts "#{model_class} start count: #{model_class.count}"
  yield
  puts "#{model_class} end count: #{model_class.count}\n"
end

def tail(file_name)
  temp = Tempfile.new(['purged', '.csv'])
  lines = File.readlines(file_name)
  size = lines.size
  temp << lines[0]
  lines[-50000..-1].each { |ln| temp << ln } # TODO: should be date based
  temp.rewind
  puts "copied last 50000 lines of #{file_name} to temp file @ #{temp.path}"
  yield temp
  temp.close
  temp.unlink
end

def import(file_name)
  tail(file_name) do |file|
    svc = ImportInvoiceHeadersCSV.new(file)
    svc.run! rescue binding.pry
  end
end

print_counts(InvoiceHeader) do
  import("../data/hhhordhp.csv")
end
