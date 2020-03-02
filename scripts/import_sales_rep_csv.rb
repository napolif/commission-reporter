require "csv"

if ARGV.empty?
  puts "usage: rails runner scripts/import_sales_rep_csv.rb <csv_file>"
  exit
end

csv = CSV.read(File.join(ARGV.first), headers: true)

sales_reps = csv.map do |row|
  SalesRep.new(
    code: row["SLS CODE"],
    name: row["NAME"],
    quota_type: if row["S/O"] == "S" then "revenue" else "profit" end,
    disabled: false,

    period1: row["P1 %"],
    period2: row["P2 %"],
    period3: row["P3 %"],
    period4: row["P4 %"],
    period5: row["P5 %"],

    goal1: row["LVL 1 GOAL %"],
    goal2: row["LVL 2 GOAL %"],
    goal3: row["LVL 3 GOAL %"],
    goal4: row["LVL 4 GOAL %"],
    goal5: row["LVL 5 GOAL %"],
    goal6: row["LVL 6 GOAL %"],
    goal7: row["LVL 7 GOAL %"],
    goal8: row["LVL 8 GOAL %"],
    goal9: row["LVL 9 GOAL %"],
    goal10: row["LVL 10 GOAL %"],

    comm1: row["LVL 1 COMM %"],
    comm2: row["LVL 2 COMM %"],
    comm3: row["LVL 3 COMM %"],
    comm4: row["LVL 4 COMM %"],
    comm5: row["LVL 5 COMM %"],
    comm6: row["LVL 6 COMM %"],
    comm7: row["LVL 7 COMM %"],
    comm8: row["LVL 8 COMM %"],
    comm9: row["LVL 9 COMM %"],
    comm10: row["LVL 10 COMM %"]
  )
end

result = SalesRep.import!(sales_reps)
puts result
