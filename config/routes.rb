Rails.application.routes.draw do

  namespace :api do
    get "search", to: "cocktails#index"
    get "detail", to: "cocktails#show"
  end
end
