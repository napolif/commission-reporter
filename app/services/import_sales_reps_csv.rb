# A service for uploading a CSV file with sales reps.
class ImportSalesRepsCSV < ImportCSV
  target_class SalesRep

  field_map code:       "SLS CODE",
            name:       "NAME",
            rep_type:   "TYPE",
            disabled:   "DISABLED",
            quota_type: "S/O",
            period1:    "P1 %",
            period2:    "P2 %",
            period3:    "P3 %",
            period4:    "P4 %",
            period5:    "P5 %",
            goal1:      "LVL 1 GOAL %",
            goal2:      "LVL 2 GOAL %",
            goal3:      "LVL 3 GOAL %",
            goal4:      "LVL 4 GOAL %",
            goal5:      "LVL 5 GOAL %",
            goal6:      "LVL 6 GOAL %",
            goal7:      "LVL 7 GOAL %",
            goal8:      "LVL 8 GOAL %",
            goal9:      "LVL 9 GOAL %",
            goal10:     "LVL 10 GOAL %",
            comm1:      "LVL 1 COMM %",
            comm2:      "LVL 2 COMM %",
            comm3:      "LVL 3 COMM %",
            comm4:      "LVL 4 COMM %",
            comm5:      "LVL 5 COMM %",
            comm6:      "LVL 6 COMM %",
            comm7:      "LVL 7 COMM %",
            comm8:      "LVL 8 COMM %",
            comm9:      "LVL 9 COMM %",
            comm10:     "LVL 10 COMM %"

  natural_key :code

  upsert true

  def transform_field_quota_type(val)
    case val
    when "S"
      "revenue"
    when "O"
      "profit"
    else
      "revenue"
    end
  end
end
