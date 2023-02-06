# import account entries (retalix purged a/r)

require 'logger'

@logger = Logger.new(STDOUT)

# :reek:UtilityFunction
def import(file_name)
  File.open(file_name, encoding: "ibm437:utf-8") do |file|
    svc = ImportCSVSalesReps.new(file, logger: @logger)
    svc.run
  end
end

# :reek:UtilityClass
def disable(code)
  SalesRep.find_by(code: code).update!(disabled: true)
end

import("import/sales_reps.csv")
