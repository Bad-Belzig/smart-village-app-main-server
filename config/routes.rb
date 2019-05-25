Rails.application.routes.draw do
  get 'data_provider/edit', as: :data_provider
  post 'data_provider/update', as: :update_data_provider

  use_doorkeeper do
    controllers :applications => 'oauth/applications'
  end

  devise_for :users

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  post "/graphql", to: "graphql#execute"

  root to: "oauth/applications#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
