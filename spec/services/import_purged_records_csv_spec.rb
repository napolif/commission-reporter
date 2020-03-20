require "rails_helper"

RSpec.describe ImportPurgedRecordsCSV do
  let(:csv_path) { path_to_csv("purged_records.csv") }
  let(:service) { ImportPurgedRecordsCSV.new(csv_path) }

  context "before import" do
    it "is valid for valid headers" do
      expect(service).to be_valid
    end
  end

  context "with empty PurgedRecord table" do
    it "creates records" do
      expect { service.run }.to change { PurgedRecord.count }.from(0).to(22)
    end

    it "is still valid after import" do
      expect { service.run }.not_to change { service.valid? }
    end

    it "has no errors after import" do
      service.run
      expect(service.errors).to be_empty
    end
  end
end
