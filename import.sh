set -e

time bin/rails r scripts/import/csv/customers.rb
time bin/rails r scripts/import/csv/purged_records.rb
time bin/rails r scripts/import/csv/invoice_headers.rb

sudo reboot now
