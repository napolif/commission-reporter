grouped = PurgedRecord.all.group_by(&:number)
counts = grouped.transform_values(&:size)

counts.values.uniq # => [2, 3, 1, 4, 5, 6, 16, 9, 10]
counts.first # => ["772991", 2]
nums = counts.keys;
nums.size # => 5821


InvoiceHeader.find_by(number: 772991)
# => #<InvoiceHeader:0x00007ff6cbe569f0
#  id: 457260,
#  number: "772991",
#  rep_code: "DC",
#  customer_code: "HOPBRK",
#  amount: 1984.13,
#  cost: 1698.16,
#  order_date: Thu, 20 Feb 2020,
#  qty_ord: 55, ...


InvoiceHeader.where(number: counts.keys).count # => 5787
InvoiceSummary.where.not(paid_on: nil).count   # => 2615
PurgedRecord.all.pluck(:number).uniq.count     # => 5821


InvoiceHeader.where(number: counts.keys).order(:order_date).first
# => #<InvoiceHeader:0x00007ff6d008a4c0
#  id: 349260,
#  number: "661018",
#  rep_code: "JB",
#  customer_code: "RIZZBE",
#  amount: 924.05,
#  cost: 806.01,
#  order_date: Thu, 17 Jan 2019,
#  qty_ord: 22, ...

PurgedRecord.where(ref_number: nil).count
# => 10108

PurgedRecord.where.not(ref_number: nil).count
# => 2292

PurgedRecord.all.pluck(:number).uniq.sort.drop(10).take(10)
# => ["31120", "4406317", "598586", "62215", "63260", "661018", "679387", "680309", "681956", "697700"]

InvoiceHeader.pluck(:number).sort.take(10)
# => ["656572", "656573", "656574", "656575", "656576", "656577", "656578", "656580", "656581", "656582"]


# -- all of the invoice summaries whose inv number appears in the
#    purged records have a paid on date
InvoiceSummary.where(number: nums).count # => 2615
InvoiceSummary.where(number: nums).where.not(paid_on: nil).count # => 2615
InvoiceSummary.where(number: nums).where(paid_on: nil).count # => 0

InvoiceHeader.where(number: nums).count
# => 5787

InvoiceHeader.all.pluck(:number).sort.first
# => "656572"
early_inv = InvoiceHeader.find_by(number: 656574)


pr = PurgedRecord.find(112526)
com = Commission.new(pr)

# ------------------------------------------------------------------------------

range = (Date.today - 1.week)..Date.today

all_ar = PurgedRecord.where(created_date: range);
all_ar.count # => 4271

all_ar = PurgedRecord.where(created_date: range).includes(invoice_header: :sales_rep);
good_ar = all_ar.where.not(invoice_headers: {id: nil});
good_ar.count # => 4224

bad_ar = all_ar.where(invoice_headers: {id: nil});
bad_ar.count # => 47

grouped_ar = good_ar.group_by(&:number);
grouped_ar.size # => 1942

InvoiceSummary.where(paid_on: range).count # => 1143

# ------------------------------------------------------------------------------

range = (Date.today - 2.week)..(Date.today - 1.week)

all_ar = PurgedRecord.where(created_date: range);
all_ar.count # => 5788

all_ar = PurgedRecord.where(created_date: range).includes(invoice_header: :sales_rep);
good_ar = all_ar.where.not(invoice_headers: {id: nil});
good_ar.count # => 5753

bad_ar = all_ar.where(invoice_headers: {id: nil});
bad_ar.count # => 35

grouped_ar = good_ar.group_by(&:number);
grouped_ar.size # => 2691

InvoiceSummary.where(paid_on: range).count # => 1329

# when there's one, it's always zero
ones = PurgedRecord.all.group_by(&:number).select { |k,v| v.size == 1 };
ones.select { |k, v| v.first.amount != 0 }.size # => 0


# when there are two, they either cancel each other out or have the same amt
twos = PurgedRecord.all.group_by(&:number).select { |k,v| v.size == 2 };
twos.select { |k, v| v[0].amount.abs != v[1].amount.abs }.size # => 0

twos.select { |k, v| v[0].amount != v[1].amount }.size # => 1021
twos.select { |k, v| v[0].amount == v[1].amount }.size # => 4142

diffs = twos.select { |k, v| v[0].amount != v[1].amount };
