n = 5000

Benchmark.bm(35) do |x|
  x.report("Date.strptime") do
  	n.times { Date.strptime("20200318", "%Y%m%d") }
  end

  x.report("Date.strptime + rescue") do
  	n.times { Date.strptime("20200318", "%Y%m%d") rescue ArgumentError nil }
  end

  x.report("Date.strptime + rescue *") do
  	n.times { Date.strptime("20200318", "%Y%m%d") rescue nil }
  end

  x.report("Time.strptime") do
  	n.times { Time.strptime("20200318", "%Y%m%d") }
  end

  x.report("Time.strptime + rescue") do
  	n.times { Time.strptime("20200318", "%Y%m%d") rescue ArgumentError nil }
  end

  x.report("Timeliness.parse strict + format") do
    n.times { Timeliness.parse("20200318", :date, format: "%Y%m%d", strict: true) }
  end

  x.report("Timeliness.parse + format") do
    n.times { Timeliness.parse("20200318", format: "%Y%m%d") }
  end

  x.report("Timeliness.parse") do
    n.times { Timeliness.parse("20200318") }
  end
end
