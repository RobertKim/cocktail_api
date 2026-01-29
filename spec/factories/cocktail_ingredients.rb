FactoryBot.define do
  factory :cocktail_ingredient do
    association :cocktail
    association :ingredient
    measurement { "1 oz" }
  end
end
