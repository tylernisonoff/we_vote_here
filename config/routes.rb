WeVoteHere::Application.routes.draw do
  
  devise_for :users do
    get "/users/sign_out" => "devise/sessions#destroy", :as => :destroy_user_session
  end

  resources :users, except: [:edit, :update, :new, :create] do
    member do
      get :add_emails
      get :emails
    end
  end

  resources :groups
  
  resources :elections do
    member do
      get :choices # might be useless
      get :export
    end
  end

  resources :choices, only: [:update] # might be useless

  root to: 'static_pages#home'

  match '/about', to: 'static_pages#about'
  match '/terms', to: 'static_pages#terms'
  match '/privacy', to: 'static_pages#privacy'

  match 'elections/:election_id/new_group', to: 'groups#new', as: :new_election_group
  match 'groups/:group_id/new_election', to: 'elections#new', as: :new_group_election

  get "static_pages/home"
  get "static_pages/about"
  get "static_pages/terms"
  get "static_pages/privacy"

  match 'users/:id/make_primary_email/:user_email_id', to: 'users#make_primary_email', as: :make_primary_email_user
  match 'users/:id/unfollow_group/:group_id', to: 'users#unfollow_group', as: :unfollow_group_user
  match 'users/:id/save_emails', to: 'users#save_emails', as: :save_emails_user

  match 'groups/:group_id/add_voters', to: 'groups#add_voters', as: :add_voters_group
  match 'elections/:election_id/add_voters', to: 'groups#add_voters', as: :add_voters_election
  match 'elections/:election_id/add_groups', to: 'elections#add_groups', as: :add_groups_election
  match 'elections/:election_id/add_parties', to: 'elections#add_parties', as: :add_parties_election
  match 'elections/:election_id/save_groups', to: 'elections#save_groups', as: :save_groups_election

  # Votes custom routes
  match 'vote/:svc', to: 'votes#vote', as: :vote
  match 'votes/:svc/activate/:id', to: 'votes#activate', as: :activate_vote
  match 'votes/:svc/destroy/:id', to: 'votes#destroy', as: :destroy_vote
  match 'votes/:svc/status', to: 'votes#status', as: :status_vote
  match 'votes/display/:id', to: 'votes#display', as: :display_vote
  match 'votes/:svc/all', to: 'votes#all', as: :all_vote
  match 'votes/sort', to: 'votes#sort', as: :sort_vote
  # match 'votes/:svc/display/:id', to: 'votes#display', as: :display_private_vote
  # match 'votes/display/:id', to: 'votes#display', as: :display_public_vote

  match 'elections/:election_id/valid_svcs/make', to: 'valid_svcs#make', as: :make_election_valid_svcs
  match 'elections/:election_id/valid_svcs/enter', to: 'valid_svcs#enter', as: :enter_election_valid_svcs
  match 'elections/:election_id/valid_svcs/confirm', to: 'valid_svcs#confirm', as: :confirm_election_valid_svcs
  match 'elections/:election_id/add_voters', to: 'elections#add_voters', as: :add_voters_election

  match 'groups/:id/destroy', to: 'groups#destroy', as: :destroy_group
  match 'elections/:id/destroy', to: 'elections#destroy', as: :destroy_election
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
