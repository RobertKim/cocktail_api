namespace :import do
  desc "Import cocktail recipes from JSON file"
  task cocktails: :environment do
    json_file_path = Rails.root.join('db', 'seeds', 'cocktail_recipes.json')
    
    puts "Starting import from #{json_file_path}..."
    
    service = CocktailImportService.new(json_file_path.to_s)
    service.call
    
    puts "Import complete!"
    puts "  Cocktails: #{Cocktail.count}"
    puts "  Ingredients: #{Ingredient.count}"
    puts "  Relationships: #{CocktailIngredient.count}"
  end
end
