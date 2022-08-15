set -e

for name in import_customers import_purged_records import_retalix_invoice_headers
do
  echo $(time bundle exec rails runner scripts/$name.rb)
done

sudo reboot now
