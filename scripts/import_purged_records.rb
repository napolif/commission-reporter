# import retalix purged a/r records

require 'tempfile'

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
  lines[-100000..-1].each { |ln| temp << ln } # TODO: should be date based
  temp.rewind
  puts "moved last 100000 lines of #{file_name} to temp file @ #{temp.path}"
  yield temp
  temp.close
  temp.unlink
end

def import(file_name)
  tail(file_name) do |file|
    svc = ImportPurgedRecordsCSV.new(file)
    svc.run! rescue binding.pry
    puts svc.result
  end
end

# StackProf.run(mode: :cpu, out: 'tmp/stackprof.dump') do
puts "deleting purged a/r records..."
PurgedRecord.delete_all

print_counts(PurgedRecord) do
  import("../data/rrwrecwp.csv")
end
# end
