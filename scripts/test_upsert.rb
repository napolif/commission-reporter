# it should not be possible to insert an invoice twice
# upserts should update an existing invoice
# upserts should not cause each record to be checked for uniqueness

def upsert_invoice_headers
  print_counts(InvoiceHeader) do
    file = File.open("../data/hhhordhp.csv", "rb")
    svc = ImportInvoiceHeadersCSV.new(file)
    svc.run! rescue binding.pry
  end
end

def upsert_customers
  print_counts(Customer) do
    file = File.open("../data/ffdcstbp.csv", "rb")
    svc = ImportCustomersCSV.new(file)
    svc.run! rescue binding.pry
  end
end

def print_counts(model_class)
  puts "#{model_class} start count: #{model_class.count}"
  yield
  puts "#{model_class} end count: #{model_class.count}\n"
end

# ----------------------------

def invoice_header_upsert_should_not_fail
  InvoiceHeader.delete_all
  upsert_invoice_headers
  upsert_invoice_headers
end

def customer_upsert_should_not_fail
  Customer.delete_all
  upsert_customers
  upsert_customers
end

invoice_header_upsert_should_not_fail
customer_upsert_should_not_fail
