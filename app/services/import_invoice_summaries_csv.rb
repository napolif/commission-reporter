# A service for uploading the COMMFILE CSV. Similar to active_interaction classes.
class ImportInvoiceSummariesCSV < ImportCSV
  extend Memoist

  target_class InvoiceSummary

  field_map number:         "HHUINVN",
            sales_rep_code: "HHUSLNB",
            amount:         "HHUEXSN",
            cost:           "HHUEXCR",
            customer_code:  "HHUCUSN",
            customer_name:  "HHUCNMB",
            cases:          "HHUQYSA",
            invoiced_on:    "LDATE",
            paid_on:        "RDATE",
            delivered:      "HHUINVR"

  natural_keys [:number]

  upsert true

  def generate_records
    super

    batch_num = InvoiceSummary.next_batch_number + "-csv"
    records.each do |rec|
      rec.batch = batch_num
    end
  end

  def transform_field_invoiced_on(val)
    Date.strptime(val, "%m/%d/%Y") rescue nil
  end

  memoize :transform_field_invoiced_on

  def transform_field_paid_on(val)
    Date.strptime(val, "%m/%d/%Y") rescue nil
  end

  memoize :transform_field_paid_on
end
