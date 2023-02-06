# import retalix customers from csv

require 'logger'

@logger = Logger.new(STDOUT)

# :reek:UtilityFunction
def import(file_name)
  File.open(file_name, encoding: "ibm437:utf-8") do |file|
    svc = ImportCSVCustomers.new(file, logger: @logger)
    svc.run
  end
end

import("../data/ffdcstbp.csv")
