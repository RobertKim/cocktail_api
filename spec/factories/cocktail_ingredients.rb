FactoryBot.define do
  factory :cocktail_ingredient do
    cocktail { nil }
    ingredient { nil }
    measurement { "MyString" }
  end
end
