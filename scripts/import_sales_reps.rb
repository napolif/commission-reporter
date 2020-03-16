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

print_counts(SalesRep) do
  import("../data/retalix_sales_reps.csv")
end

puts "disabling a few..."

# exp
%w[505 506 513 514 522 523 524 525 526].each do |code|
  disable(code)
end

# order takers / inside / etc
%w[521 533 537 539 540 543 547 548 549 550 551].each do |code|
  disable(code)
end

# no longer
%w[417 530 532].each do |code|
  disable(code)
end

puts "done"
