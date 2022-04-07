echo `time rails runner scripts/import_customers.rb`
echo `time rails runner scripts/import_purged_records.rb`
echo `time rails runner scripts/import_retalix_invoice_headers.rb`
# sudo reboot now
