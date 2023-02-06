require "rails_helper"

RSpec.describe ImportCSVSalesReps do
  let(:csv_path) { data_path("sales_reps.csv") }
  let(:service) { described_class.new(File.new(csv_path)) }

  context "with empty SalesRep table" do
    it "is valid for valid headers" do
      expect(service).to be_valid
    end

    it "creates records" do
      expect { service.run }.to change(SalesRep, :count).from(0).to(3)
    end

    it "is still valid after import" do
      expect { service.run }.not_to change(service, :valid?)
    end

    it "has no errors after import" do
      service.run
      expect(service.errors).to be_empty
    end
  end

  context "with existing SalesRep records" do
    let(:csv_path) { data_path("sales_reps2.csv") }

    # TODO: don't use the importer to set up the test
    before { described_class.new(File.new(data_path("sales_reps.csv"))).run }

    it "does not create new records" do
      expect { service.run }.not_to change(SalesRep, :count)
    end

    it "is still valid after import" do
      expect { service.run }.not_to change(service, :valid?)
    end

    it "has no errors after import" do
      service.run
      expect(service.errors).to be_empty
    end

    it "updates records where necessary" do
      sales_rep = SalesRep.find_by(name: "Albert Einstein")
      expect { service.run }
        .to(change { sales_rep.reload.disabled }
        .from(true)
        .to(false))
    end
  end
end
