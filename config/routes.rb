WeVoteHere::Application.routes.draw do
  
  resources :groups do
    resources :elections, only: [:index, :new, :create]
    member do
      get :add_voters
    end
  end

  resources :users do
    member do
      get :groups
      get :edit_password
      put :change_password
      get :add_emails
      post :save_emails
      get :emails
    end
  end
  
  resources :elections do
    member do
      get :choices # might be useless
    end
  end

  resources :preferences, only: [] do
    post :sort, on: :collection
  end

  resources :choices, only: [:update] # might be useless

  resources :sessions, only: [:new, :create, :destroy]

  root to: 'static_pages#home'

  match '/edit',   to: 'users#edit'
  match '/signup', to: 'users#new'
  match '/signin', to: 'sessions#new'
  match '/signout', to: 'sessions#destroy', via: :delete

  match '/about', to: 'static_pages#about'
  match '/terms', to: 'static_pages#terms'
  match '/privacy', to: 'static_pages#privacy'

  match '/new_group', to: 'groups#new'
  match '/new_election', to: 'elections#new'

  get "static_pages/home"
  get "static_pages/about"
  get "static_pages/terms"
  get "static_pages/privacy"

  match 'users/:id/make_primary_email/:user_email_id', to: 'users#make_primary_email', as: :make_primary_email_user
  match 'users/:id/unfollow_group/:group_id', to: 'users#unfollow_group', as: :unfollow_group_user

  # Votes custom routes
  match 'vote/:svc', to: 'votes#vote', as: :vote
  match 'votes/:svc', to: 'votes#vote'
  match 'votes/:svc/activate/:id', to: 'votes#activate', as: :activate_vote
  match 'votes/:svc/destroy/:id', to: 'votes#destroy', as: :destroy_vote
  match 'votes/:svc/status', to: 'votes#status', as: :status_vote
  match 'votes/display/:id', to: 'votes#display', as: :display_vote
  # match 'votes/:svc/display/:id', to: 'votes#display', as: :display_private_vote
  # match 'votes/display/:id', to: 'votes#display', as: :display_public_vote

  match 'elections/:election_id/valid_svcs/make', to: 'valid_svcs#make', as: :make_election_valid_svcs
  match 'elections/:election_id/valid_svcs/enter', to: 'valid_svcs#enter', as: :enter_election_valid_svcs
  match 'elections/:election_id/valid_svcs/confirm', to: 'valid_svcs#confirm', as: :confirm_election_valid_svcs


  match 'elections/:id/results', to: 'elections#results', as: :results_election
  match 'elections/:id/mov/export', to: 'elections#export_mov_to_csv', as: :export_mov_to_csv_election
  match 'elections/:id/votes/export', to: 'elections#export_votes_to_csv', as: :export_votes_to_csv_election
  match 'elections/:id/ranked_pairs/export', to: 'elections#export_ranked_pairs_to_txt', as: :export_ranked_pairs_to_txt

# -----------------------------------------------------------------------

  # special cases where we need to make then enter their SVC, perhaps as a cookie

  # match 'elections/:id/:svc/export_mov_to_csv', to: 'elections#export_mov_to_csv', as: :export_mov_to_csv_election
  # match 'elections/:id/:svc/export_votes_to_csv', to: 'elections#export_votes_to_csv', as: :export_votes_to_csv_election
  # match 'elections/:id/:svc/results', to: 'elections#results', as: :results_election
  # match 'elections/:id/:svc', to: 'elections#show', as: :election
  # match 'elections/:svc', to: 'elections#index', as: :index_election


# -----------------------------------------------------------------------


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
