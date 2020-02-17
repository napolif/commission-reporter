reps = SalesRep.all

reps.each do |rep|
  if rep.comm_type == "S"
    rep.comm_type = "revenue"
  end

  if rep.comm_type == "O"
    rep.comm_type = "profit"
  end

  rep.save
end
