# == Schema Information
#
# Table name: purged_records
#
#  id            :bigint           not null, primary key
#  adj_code      :string
#  amount        :decimal(10, 2)
#  created_date  :date
#  customer_code :string
#  due_date      :date
#  number        :string
#  ref_number    :string
#  rep_code      :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_purged_records_on_adj_code  (adj_code)
#  index_purged_records_on_number    (number)
#  index_purged_records_on_rep_code  (rep_code)
#

class PurgedRecord < ApplicationRecord
  include Importable
end
