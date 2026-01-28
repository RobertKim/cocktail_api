class AddIndexesToCocktails < ActiveRecord::Migration[7.2]
  def change
    add_index :cocktails, :name, unique: true
  end
end
