require "rails_helper"

RSpec.describe ImportCSVPurgedRecords do
  let(:csv_path) { data_path("purged_records.csv") }
  let(:service) { described_class.new(File.new(csv_path)) }

  context "with empty PurgedRecord table" do
    it "is valid for valid headers" do
      expect(service).to be_valid
    end

    it "creates records" do
      expect { service.run }.to change(PurgedRecord, :count).from(0).to(22)
    end

    it "is still valid after import" do
      expect { service.run }.not_to change(service, :valid?)
    end

    it "has no errors after import" do
      service.run
      expect(service.errors).to be_empty
    end
  end
end
