require 'rails_helper'

RSpec.describe CocktailIngredient, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:measurement) }
  end

  describe 'associations' do
    it { should belong_to(:cocktail) }
    it { should belong_to(:ingredient) }
  end
end
