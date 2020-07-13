require "rails_helper"

RSpec.describe ImportCustomersCSV do
  let(:csv_path) { path_to_csv("customers.csv") }
  let(:service) { ImportCustomersCSV.new(csv_path) }

  context "before import" do
    it "is valid for valid headers" do
      expect(service).to be_valid
    end
  end

  context "with empty Customer table" do
    it "creates records" do
      expect { service.run }.to change { Customer.count }.from(0).to(8)
    end

    it "is still valid after import" do
      expect { service.run }.not_to change { service.valid? }
    end

    it "has no errors after import" do
      service.run
      expect(service.errors).to be_empty
    end
  end

  context "with existing Customer records" do
    let(:csv_path) { path_to_csv("customers2.csv") }
    let(:customer) { Customer.find_by(code: "ILLIAN") }

    before { ImportCustomersCSV.new(path_to_csv("customers.csv")).run }

    it "does not create new records" do
      expect { service.run }.not_to change { Customer.count }
    end

    it "is still valid after import" do
      expect { service.run }.not_to change { service.valid? }
    end

    it "has no errors after import" do
      service.run
      expect(service.errors).to be_empty
    end

    it "updates records where necessary" do
      expect { service.run }
        .to(change { customer.reload.name }
        .from("ILLIANO'S ( WATERFORD )")
        .to("ILLIANO'S ( WATERBURY )"))
    end
  end

  context "with customer CSV containing alternate company divisions" do
    let(:csv_path) { path_to_csv("customers3.csv") }

    it "ignores records that do not have company division 1/6/6" do
      expect { service.run }.to change { Customer.count }.from(0).to(1)
    end
  end
end
