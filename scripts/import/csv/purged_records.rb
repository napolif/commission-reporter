# import retalix purged a/r

require 'logger'

@logger = Logger.new(STDOUT)

# :reek:UtilityFunction
def import(file_name)
  File.open(file_name, encoding: "ibm437:utf-8") do |file|
    svc = ImportCSVPurgedRecords.new(file, logger: @logger)
    svc.run
  end
end

@logger.info "deleting PurgedRecords..."
PurgedRecord.delete_all
import("../data/rrwrecwp.csv")
