class Cocktail < ApplicationRecord
  has_many :cocktail_ingredients, dependent: :destroy
  has_many :ingredients, through: :cocktail_ingredients

  validates :name, presence: true
end
