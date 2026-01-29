require 'rails_helper'

RSpec.describe Cocktail, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { should have_many(:cocktail_ingredients).dependent(:destroy) }
    it { should have_many(:ingredients).through(:cocktail_ingredients) }
  end
end
