class AddIndexesToCocktails < ActiveRecord::Migration[7.2]
  def change
    # Index on name for search performance (case-insensitive search)
    add_index :cocktails, :name
  end
end
