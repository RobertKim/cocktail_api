Rails.application.routes.draw do

  namespace :api do
    # Routes match spec exactly but use single RESTful controller
    # Tradeoff: Spec URLs vs. RESTful conventions
    # - Spec requires: /api/search and /api/detail (non-RESTful URLs)
    # - RESTful would be: /api/cocktails (index) and /api/cocktails/:id (show)
    # - Solution: Use single controller (RESTful) but route to spec URLs
    get "search", to: "cocktails#index"
    get "detail", to: "cocktails#show"
  end
end
