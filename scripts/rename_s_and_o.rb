reps = SalesRep.all

reps.each do |rep|
  rep.comm_type = "revenue" if rep.comm_type == "S"
  rep.comm_type = "profit" if rep.comm_type == "O"
  rep.save!
end
