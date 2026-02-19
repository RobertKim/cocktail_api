# Cocktail API

A production-style Rails API that exposes cocktail recipe data through a clean, contract-driven interface. Built as a backend service for search and detail workflows, with a focus on **normalized data modeling**, **idempotent ingestion**, and **predictable API behavior**.

---

## What This Project Demonstrates

- **Structured data ingestion**: JSON-based import with validation, error handling, and deterministic normalization (e.g. ingredient names) so re-runs don’t create duplicates.
- **Deliberate schema design**: Normalized domain model—cocktails, ingredients, and a join table with measurements—so ingredients are reusable and queryable across recipes.
- **API design**: Search and detail endpoints with pagination, bounds checking, and consistent error responses (400 for bad input, 404 for missing resources).
- **Performance awareness**: Eager loading on detail responses to avoid N+1 queries when serving cocktails with ingredients.
- **Test coverage**: RSpec suite covering models (validations, associations), request-level API behavior (pagination, search, errors, response shape), and the import service (idempotency, normalization, failure cases).

---

## How It Can Be Used

- **Mobile or web app backend**: Consume search and detail from a frontend; pagination and strict response contracts make integration straightforward.
- **Bar or menu services**: Power drink menus, “what can I make?” features, or inventory-aware suggestions by querying cocktails and ingredients.
- **Content or CMS integration**: Treat as a headless content source; import can be re-run or extended for new data sources without breaking existing clients.
- **Larger platform piece**: Fits as the “recipes” service in a larger system (e.g. user accounts, favorites, or recommendations built on top of the same data).

---

## Requirements

- Ruby 3.1+ (project uses Ruby 3.4.6)
- Bundler
- SQLite3

---

## Setup

1. **Install dependencies**
   ```bash
   bundle install
   ```

2. **Create and migrate the database**
   ```bash
   bundle exec rails db:create
   bundle exec rails db:migrate
   ```

3. **Load recipe data** (idempotent; safe to run multiple times)
   ```bash
   bundle exec rails import:cocktails
   ```

4. **Run the test suite**
   ```bash
   bundle exec rspec
   ```

---

## Running the Server

```bash
bundle exec rails server
```

API base: `http://localhost:3000`

---

## API Reference

### Search — `GET /api/search`

Returns cocktails with pagination and optional name search.

| Parameter | Type    | Default | Description |
|-----------|---------|---------|-------------|
| `index`   | integer | 0       | Pagination offset |
| `limit`   | integer | 10      | Page size (max 50) |
| `query`   | string  | —       | Case-insensitive substring match on cocktail name |

**Example:** `GET /api/search?query=rita&limit=5`

**Response:** JSON object with a `drinks` array; each item includes `id`, `name`, `category`, and `image`. No container, instructions, or ingredients at this level.

---

### Detail — `GET /api/detail`

Returns a single cocktail by ID with full metadata and ingredients.

| Parameter | Type    | Required | Description |
|-----------|---------|-----------|-------------|
| `id`      | integer | Yes      | Cocktail ID |

**Example:** `GET /api/detail?id=1`

**Response:** JSON object with a `drinks` array (one element); each item includes `id`, `name`, `category`, `container`, `instructions`, `image`, and `ingredients` (array of `name` and `measurement`).

**Errors:**
- `400 Bad Request` — missing or invalid `id`
- `404 Not Found` — no cocktail for the given `id`

---

## Database Schema

| Table                | Purpose |
|----------------------|---------|
| `cocktails`          | Core recipe data: name, category, container, instructions, image_url |
| `ingredients`        | Unique ingredient names (normalized, e.g. lowercase) |
| `cocktail_ingredients` | Join table: cocktail_id, ingredient_id, measurement |

Ingredients are shared across cocktails; the join table stores the measurement per recipe.

---

## Design Notes

- **Ingredient normalization**: Names are lowercased and trimmed on import to avoid duplicate ingredients from casing or spacing differences.
- **Idempotent import**: Import uses find-or-create semantics and refreshes cocktail–ingredient links per run, so re-running the task doesn’t create duplicate cocktails or orphaned data.
- **Search**: Case-insensitive `LIKE` on cocktail name; pagination is offset-based with configurable index and limit.
- **Errors**: Invalid or missing parameters and missing resources return appropriate HTTP status codes and JSON error payloads.

---

## License

See repository or project root for license information.
