# import retalix purged a/r records

def print_counts(model_class)
  puts "#{model_class} start count: #{model_class.count}"
  yield
  puts "#{model_class} end count: #{model_class.count}\n"
end

def import(file_name)
  file = File.open(file_name, "rb")
  svc = ImportPurgedRecordsCSV.new(file)
  svc.run! rescue binding.pry
  puts svc.result
end

print_counts(PurgedRecord) do
  import("../data/rrwrecwp.csv")
end
