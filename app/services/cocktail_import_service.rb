class CocktailImportService
  def initialize(json_file_path)
    @json_file_path = json_file_path
  end

  def call
    cocktail_data_array = parse_json_file
    import_cocktails(cocktail_data_array)
  end

  private

  attr_reader :json_file_path

  def parse_json_file
    file_contents = File.read(json_file_path)
    JSON.parse(file_contents)
  rescue Errno::ENOENT => e
    raise ArgumentError, "JSON file not found: #{json_file_path}"
  rescue JSON::ParserError => e
    raise ArgumentError, "Invalid JSON format: #{e.message}"
  end

  def import_cocktails(cocktail_data_array)
    cocktail_data_array.each do |cocktail_data|
      import_cocktail(cocktail_data)
    end
  end

  def import_cocktail(cocktail_data)
    ActiveRecord::Base.transaction do
      cocktail = Cocktail.find_or_create_by(name: cocktail_data['name']) do |c|
        c.category = cocktail_data['category']
        c.container = cocktail_data['container']
        c.instructions = cocktail_data['instructions']
        c.image_url = cocktail_data['image']
      end

      cocktail.update(
        category: cocktail_data['category'],
        container: cocktail_data['container'],
        instructions: cocktail_data['instructions'],
        image_url: cocktail_data['image']
      )

      cocktail.cocktail_ingredients.destroy_all
      cocktail_data['ingredients']&.each do |ingredient_data|
        import_cocktail_ingredient(cocktail, ingredient_data)
      end
    end
  end

  def import_cocktail_ingredient(cocktail, ingredient_data)
    normalized_name = normalize_ingredient_name(ingredient_data['name'])
    ingredient = Ingredient.find_or_create_by(name: normalized_name)

    CocktailIngredient.create(
      cocktail: cocktail,
      ingredient: ingredient,
      measurement: ingredient_data['measurement']
    )
  end

  def normalize_ingredient_name(name)
    name.to_s.downcase.strip
  end
end
