SalesRep.all.each do |rep|
  if rep.quota_type.blank?
    rep.quota_type = "profit"
    rep.save!
  end
end
