class Api::CocktailsController < ApplicationController
  def index
    index_param = parse_integer_param(params[:index], default: 0, min: 0)
    limit_param = parse_integer_param(params[:limit], default: 10, min: 1, max: 50)
    query_param = params[:query]&.strip

    cocktails = build_search_query(query_param, index_param, limit_param)

    render json: { drinks: serialize_search_results(cocktails) }
  end

  def show
    id_param = params[:id]
    
    if id_param.blank?
      render json: { error: "Missing required parameter: id" }, status: :bad_request
      return
    end

    cocktail_id = parse_id(id_param)
    
    cocktail = Cocktail.includes(:ingredients, :cocktail_ingredients)
                       .find_by(id: cocktail_id)

    if cocktail.nil?
      render json: { error: "Cocktail not found" }, status: :not_found
      return
    end

    render json: { drinks: [serialize_detail_result(cocktail)] }
  end

  private

  def parse_integer_param(value, default:, min: nil, max: nil)
    return default if value.blank?

    integer_value = value.to_i
    return default if integer_value == 0 && value != "0"

    integer_value = [integer_value, min].max if min
    integer_value = [integer_value, max].min if max
    integer_value
  end

  def build_search_query(query, index, limit)
    base_query = Cocktail.all

    if query.present?
      base_query = base_query.where("LOWER(name) LIKE ?", "%#{query.downcase}%")
    end

    base_query.order(:name).offset(index).limit(limit)
  end

  def serialize_search_results(cocktails)
    cocktails.map do |cocktail|
      {
        id: cocktail.id,
        name: cocktail.name,
        category: cocktail.category,
        image: cocktail.image_url
      }
    end
  end

  def parse_id(id_param)
    id_param.to_i if id_param.present? && id_param.to_i.to_s == id_param.to_s
  end

  def serialize_detail_result(cocktail)
    {
      id: cocktail.id,
      name: cocktail.name,
      category: cocktail.category,
      container: cocktail.container,
      instructions: cocktail.instructions,
      image: cocktail.image_url,
      ingredients: serialize_ingredients(cocktail)
    }
  end

  def serialize_ingredients(cocktail)
    cocktail.cocktail_ingredients.includes(:ingredient).map do |ci|
      {
        name: ci.ingredient.name,
        measurement: ci.measurement
      }
    end
  end
end