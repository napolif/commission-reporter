require "rails_helper"

RSpec.describe ImportSalesRepsCSV do
  let(:csv_path) { path_to_csv("sales_reps.csv") }
  let(:service) { ImportSalesRepsCSV.new(csv_path) }

  context "before import" do
    it "is valid for valid headers" do
      expect(service).to be_valid
    end
  end

  context "with empty SalesRep table" do
    it "creates records" do
      expect { service.run }.to change { SalesRep.count }.from(0).to(3)
    end

    it "is still valid after import" do
      expect { service.run }.not_to change { service.valid? }
    end

    it "has no errors after import" do
      service.run
      expect(service.errors).to be_empty
    end
  end

  context "with existing SalesRep records" do
    let(:csv_path) { path_to_csv("sales_reps2.csv") }
    let(:salesrep) { SalesRep.find_by(name: "Albert Einstein") }

    before { ImportSalesRepsCSV.new(path_to_csv("sales_reps.csv")).run }

    it "does not create new records" do
      expect { service.run }.not_to change { SalesRep.count }
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
        .to(change { salesrep.reload.disabled }
        .from(true)
        .to(false))
    end
  end
end
