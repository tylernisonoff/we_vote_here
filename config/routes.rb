WeVoteHere::Application.routes.draw do
  
  resources :elections do
    resources :questions
  end

  resources :users do
    member do
      get :elections
    end
  end

  resources :questions do
    resources :votes
    resources :valid_svcs do
      get :enter, on: :collection
      get :make, on: :collection
      post :confirm, on: :collection
    end
    member do
      get :candidates
    end
  end

  resources :valid_svcs

  resources :preferences do
    post :sort, on: :collection
  end

  resources :candidates

  resources :votes do
    member do
      get :display
      get :status
      get :activate
      get :clear
    end
  end

  resources :sessions, only: [:new, :create, :destroy]

  root to: 'static_pages#home'

  match '/edit',   to: 'users#edit'
  match '/signup', to: 'users#new'
  match '/signin', to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete

  match '/about', to: 'static_pages#about'
  match '/terms', to: 'static_pages#terms'
  match '/privacy', to: 'static_pages#privacy'

  match '/new_election', to: 'elections#new'
  match '/new_question', to: 'questions#new'
  
  match 'votes/save_preferences', to: 'votes#save_preferences'

  get "static_pages/home"
  get "static_pages/about"
  get "static_pages/terms"
  get "static_pages/privacy"


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
