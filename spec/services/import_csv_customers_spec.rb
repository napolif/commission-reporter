require "rails_helper"

RSpec.describe ImportCSVCustomers do
  let(:csv_path) { data_path("customers.csv") }
  let(:service) { described_class.new(File.new(csv_path)) }

  context "with empty Customer table" do
    it "is valid for valid headers" do
      expect(service).to be_valid
    end

    it "creates records" do
      expect { service.run }.to change(Customer, :count).from(0).to(8)
    end

    it "is still valid after import" do
      expect { service.run }.not_to change(service, :valid?)
    end

    it "has no errors after import" do
      service.run
      expect(service.errors).to be_empty
    end
  end

  context "with existing Customer records" do
    before do
      [{code: "ILLIAN", name: "ILLIANO'S ( WATERBURY )"},
       {code: "ILLIC1", name: "ILLIANO'S ( COLCHESTER )"},
       {code: "ILLIM2", name: "ILLIANO'S ( 2 MIDDLETOWN"},
       {code: "ILLIM1", name: "ILLIANO'S ( MERIDEN )"},
       {code: "ILLIMI", name: "ILLIANO'S ( MIDDLETOWN )"},
       {code: "ILLINW", name: "ILLIANO'S NORTH WINDHAM"},
       {code: "ILLINY", name: "ILLIANO'S ( NIANTIC )"},
       {code: "ILLIYA", name: "ILLIANO'S ( YANTIC )"}].each do |line|
         Customer.create(location: 6, **line)
       end
    end

    let(:customer) { Customer.find_by(code: "ILLIAN") }

    it "does not create new records" do
      expect { service.run }.not_to change(Customer, :count)
    end

    it "is still valid after import" do
      expect { service.run }.not_to change(service, :valid?)
    end

    it "has no errors after import" do
      service.run
      expect(service.errors).to be_empty
    end

    it "updates records where necessary" do
      customer.update(name: "TEST CUSTOMER")

      expect { service.run }
        .to(change { customer.reload.name }
        .from("TEST CUSTOMER")
        .to("ILLIANO'S ( WATERFORD )"))
    end
  end

  context "with customer CSV containing duplicate customers" do
    let(:csv_path) { data_path("customers-dup.csv") }

    # :reek:UtilityFunction
    def row_count(path)
      lines = File.foreach(path).reduce(0) { |count, _line| count + 1 }
      lines - 1 # exclude header
    end

    it "skips the second one" do
      expect(row_count(csv_path)).to eq(3)
      expect { service.run }.to change(Customer, :count).from(0).to(2)
    end
  end
end
