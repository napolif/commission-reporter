# import retalix purged a/r records

def print_counts(model_class)
  puts "#{model_class} start count: #{model_class.count}"
  yield
  puts "#{model_class} end count: #{model_class.count}\n"
end

def import(file_name)
  file = File.open(file_name, "rb")
  svc = ImportPurgedRecordsCSV.new(file)
  svc.run! # rescue binding.pry
end

# StackProf.run(mode: :cpu, out: 'tmp/stackprof.dump') do
puts "deleting purged a/r records..."
PurgedRecord.delete_all

print_counts(PurgedRecord) do
  import("../data/rrwrecwp.csv")
end
# end
