require 'rails_helper'

RSpec.describe "Api::Cocktails", type: :request do
  describe "GET /api/search" do
    let!(:cocktail1) { create(:cocktail, name: "Margarita", category: "Cocktail") }
    let!(:cocktail2) { create(:cocktail, name: "Old Fashioned", category: "Ordinary Drink") }
    let!(:cocktail3) { create(:cocktail, name: "Mojito", category: "Cocktail") }

    it "returns default pagination when no parameters" do
      get "/api/search"
      
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json["drinks"]).to be_an(Array)
      expect(json["drinks"].length).to eq(3)
    end

    it "respects index and limit parameters" do
      10.times { |i| create(:cocktail, name: "Drink #{i}") }
      
      get "/api/search", params: { index: 2, limit: 5 }
      
      json = JSON.parse(response.body)
      expect(json["drinks"].length).to eq(5)
    end

    it "searches by name substring (case-insensitive)" do
      get "/api/search", params: { query: "rita" }
      
      json = JSON.parse(response.body)
      expect(json["drinks"].length).to eq(1)
      expect(json["drinks"].first["name"]).to eq("Margarita")
    end

    it "returns all cocktails when query is blank" do
      get "/api/search", params: { query: "" }
      
      json = JSON.parse(response.body)
      expect(json["drinks"].length).to eq(3)
    end

    it "returns response matching API contract" do
      get "/api/search"
      
      json = JSON.parse(response.body)
      drink = json["drinks"].first
      expect(drink).to have_key("id")
      expect(drink).to have_key("name")
      expect(drink).to have_key("category")
      expect(drink).to have_key("image")
      expect(drink).not_to have_key("container")
    end
  end

  describe "GET /api/detail" do
    let!(:ingredient1) { create(:ingredient, name: "vodka") }
    let!(:ingredient2) { create(:ingredient, name: "lime juice") }
    let!(:cocktail) do
      c = create(:cocktail, name: "Vodka Lime", category: "Cocktail", 
                 container: "Highball glass", 
                 instructions: "Mix and serve",
                 image_url: "https://example.com/vodka-lime.jpg")
      create(:cocktail_ingredient, cocktail: c, ingredient: ingredient1, measurement: "2 oz")
      create(:cocktail_ingredient, cocktail: c, ingredient: ingredient2, measurement: "1 oz")
      c
    end

    it "returns cocktail with nested ingredients" do
      get "/api/detail", params: { id: cocktail.id }
      
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      drink = json["drinks"].first
      
      expect(drink["name"]).to eq("Vodka Lime")
      expect(drink["ingredients"]).to be_an(Array)
      expect(drink["ingredients"].length).to eq(2)
      expect(drink["ingredients"].first).to have_key("name")
      expect(drink["ingredients"].first).to have_key("measurement")
    end

    it "returns 400 when id is missing" do
      get "/api/detail"
      
      expect(response).to have_http_status(:bad_request)
    end

    it "returns 404 when id not found" do
      get "/api/detail", params: { id: 99999 }
      
      expect(response).to have_http_status(:not_found)
    end

    it "returns response matching API contract" do
      get "/api/detail", params: { id: cocktail.id }
      
      json = JSON.parse(response.body)
      drink = json["drinks"].first
      expect(drink).to have_key("id")
      expect(drink).to have_key("name")
      expect(drink).to have_key("category")
      expect(drink).to have_key("container")
      expect(drink).to have_key("instructions")
      expect(drink).to have_key("image")
      expect(drink).to have_key("ingredients")
    end
  end
end
