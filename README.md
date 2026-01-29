# Cocktail API

A Rails API application that serves cocktail recipe data with search and detail endpoints.

## Requirements

- Ruby 3.1+ (project uses Ruby 3.4.6)
- Bundler
- SQLite3

## Setup

1. Install dependencies:
   ```
   bundle install
   ```

2. Set up the database:
   ```
   bundle exec rails db:create
   bundle exec rails db:migrate
   ```

3. Import cocktail data:
   ```
   bundle exec rails import:cocktails
   ```

## Running Tests

```
bundle exec rspec
```

## API Endpoints

### Search Endpoint

`GET /api/search?index=<number>&limit=<number>&query=<string>`

**Parameters:**
- `index` (optional): Offset to start results from. Default: 0
- `limit` (optional): Maximum number of results. Default: 10, Max: 50
- `query` (optional): Substring to search in cocktail names (case-insensitive). If omitted or blank, returns all cocktails

**Example:**
```
GET /api/search?query=rita&limit=5
```

**Response:**
```json
{
  "drinks": [
    {
      "id": 1,
      "name": "Margarita",
      "category": "Cocktail",
      "image": "https://..."
    }
  ]
}
```

### Detail Endpoint

`GET /api/detail?id=<id>`

**Parameters:**
- `id` (required): Cocktail identifier

**Example:**
```
GET /api/detail?id=1
```

**Response:**
```json
{
  "drinks": [
    {
      "id": 1,
      "name": "Margarita",
      "category": "Cocktail",
      "container": "Cocktail glass",
      "instructions": "Mix ingredients...",
      "image": "https://...",
      "ingredients": [
        {
          "name": "tequila",
          "measurement": "2 oz"
        }
      ]
    }
  ]
}
```

## Running the Server

```
bundle exec rails server
```

The API will be available at `http://localhost:3000`

## Database Schema

- `cocktails`: Main cocktail data (name, category, container, instructions, image_url)
- `ingredients`: Ingredient names (normalized to lowercase)
- `cocktail_ingredients`: Join table linking cocktails to ingredients with measurements

## Notes

- Ingredient names are normalized to lowercase during import to prevent duplicates
- The import process is idempotent
- Search uses case-insensitive substring matching
- Pagination uses offset-based approach
