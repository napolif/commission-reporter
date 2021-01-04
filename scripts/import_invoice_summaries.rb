# import retalix commfile

def print_counts(model_class)
  puts "#{model_class} start count: #{model_class.count}"
  yield
  puts "#{model_class} end count: #{model_class.count}\n"
end

def import(file_name)
  file = File.open(file_name, "rb")
  svc = ImportInvoiceSummariesCSV.new(file)
  svc.run! rescue binding.pry
end

print_counts(InvoiceSummary) do
  import("../data/commfile.csv")
end
