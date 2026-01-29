FactoryBot.define do
  factory :cocktail do
    sequence(:name) { |n| "Cocktail #{n}" }
    category { "Ordinary Drink" }
    container { "Highball glass" }
    instructions { "Mix ingredients and serve" }
    image_url { "https://example.com/image.jpg" }
  end
end
