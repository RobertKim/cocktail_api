require 'rails_helper'

RSpec.describe CocktailImportService do
  let(:json_file_path) { Rails.root.join('spec', 'fixtures', 'sample_cocktails.json') }
  let(:service) { described_class.new(json_file_path.to_s) }

  before do
    sample_data = [
      {
        "name" => "Test Cocktail",
        "category" => "Test Category",
        "container" => "Test Glass",
        "instructions" => "Test instructions",
        "image" => "https://example.com/test.jpg",
        "ingredients" => [
          { "name" => "Vodka", "measurement" => "2 oz" },
          { "name" => "Lime Juice", "measurement" => "1 oz" }
        ]
      }
    ]

    FileUtils.mkdir_p(File.dirname(json_file_path))
    File.write(json_file_path, JSON.generate(sample_data))
  end

  after do
    File.delete(json_file_path) if File.exist?(json_file_path)
  end

  describe "#call" do
    it "imports cocktails and ingredients from JSON" do
      expect {
        service.call
      }.to change { Cocktail.count }.by(1)
        .and change { Ingredient.count }.by(2)
    end

    it "normalizes ingredient names to lowercase" do
      service.call
      
      expect(Ingredient.pluck(:name)).to contain_exactly("vodka", "lime juice")
    end

    it "creates cocktail-ingredient relationships" do
      service.call
      
      cocktail = Cocktail.find_by(name: "Test Cocktail")
      expect(cocktail.ingredients.count).to eq(2)
    end

    it "is idempotent (running twice does not create duplicates)" do
      service.call
      initial_counts = { cocktails: Cocktail.count, ingredients: Ingredient.count }
      
      service.call
      
      expect(Cocktail.count).to eq(initial_counts[:cocktails])
      expect(Ingredient.count).to eq(initial_counts[:ingredients])
    end

    context "error handling" do
      it "raises error for missing file" do
        missing_service = described_class.new("/nonexistent/file.json")
        
        expect {
          missing_service.call
        }.to raise_error(ArgumentError, /not found/)
      end

      it "raises error for invalid JSON" do
        File.write(json_file_path, "invalid json {")
        invalid_service = described_class.new(json_file_path.to_s)
        
        expect {
          invalid_service.call
        }.to raise_error(ArgumentError, /Invalid JSON/)
      end
    end
  end
end
