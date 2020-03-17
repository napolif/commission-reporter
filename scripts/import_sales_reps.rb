# import alpha & retalix sales reps

def print_counts(model_class)
  puts "#{model_class} start count: #{model_class.count}"
  yield
  puts "#{model_class} end count: #{model_class.count}\n"
end

def import(file_name)
  file = File.open(file_name, "rb")
  svc = ImportSalesRepsCSV.new(file)
  svc.run! rescue binding.pry
  puts svc.result
end

def disable(code)
  SalesRep.find_by(code: code).update!(disabled: true)
end

# SalesRep.where.not(code: "_DEF").delete_all

print_counts(SalesRep) do
  import("../data/sales_reps.csv")
end
