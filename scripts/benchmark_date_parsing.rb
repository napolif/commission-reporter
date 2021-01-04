n = 1000

Benchmark.bm do |x|
  x.report do
  	n.times { Date.strptime("20200318", "%Y%m%d") }
  end

  x.report do
  	n.times { Time.strptime("20200318", "%Y%m%d") }
  end

  x.report do
    n.times { Timeliness.parse("20200318", :date, format: "%Y%m%d", strict: true) }
  end

  x.report do
    n.times { Timeliness.parse("20200318", format: "%Y%m%d") }
  end

  x.report do
    n.times { Timeliness.parse("20200318") }
  end
end
