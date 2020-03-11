# A service for uploading a CSV file with customer data.
class ImportCustomersCSV < ImportCSV
  target_class Customer

  index_field code: "FFDCUSN"

  field_map code: "FFDCUSN", name: "FFDCNMB"
end
