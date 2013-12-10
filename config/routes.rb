TalksTokyo::Application.routes.draw do
  resources :posted_talks do
    member do
      get :delete
      get :approve
    end
  end
  resources :tickles

  resources :talks do
    resources :associations, :except => [:index], :type => 'talk' do
      delete :destroy, :on => :collection
    end
    member do
      get :delete
      post :cancel
    end
    collection do
      get :help
      get :venue_list
      get :speaker_email_list
      get :speaker_name_list
    end
  end
  namespace :talks, :path => '/talks/:id' do
    resource :special_message, only: [:edit, :update]
  end
  match "/talks/:talk_id/associations", :to => "associations#new", :type => 'talk'

  resources :lists, :except => [:show] do
    resources :associations, :except => [:index], :type => 'list' do
      delete :destroy, :on => :collection
    end
    resource :talks, :controller => 'associations', :only => [:edit], :type => 'talk'
    resource :lists, :controller => 'associations', :only => [:edit], :type => 'list'
    resources :managers, :controller => 'list_user' do
      get :edit, :on => :collection
    end
    member do
      get :edit_details
      get :details
      get :delete
      get :show_talk_post_url
      post :generate_talk_post_url
    end
    get :choose, :on => :collection
  end
  match "/lists/:list_id/associations", :to => "associations#new", :type => 'list'
  match 'lists/:id', :to => 'show#index', :as => 'list'

  resources :venues

  resources :users do
    member do
      get 'change_password'
      post 'suspend'
      post 'unsuspend'
    end
  end

  resources :documents do
    resources :revisions, :only => [:show], :to => 'documents#show'
    get :changes, :on => :collection,  :to => 'documents#recent_changes'
  end

  resources :images, :only => [:show, :destroy] do
    get :delete, :on => :member
  end

  root :to => 'home#index', :as => 'home'
  match 'home(/:action)', :to => 'home#index'

  match 'styles/lists', :to => 'styles#lists', :as => 'lists_styles'

  match 'search/' => 'search#results', :as => 'search'
  # match 'search/:search' => 'search#results', :search => nil
  match 'search/results' => 'search#results'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  # map.connect ':controller/service.wsdl', :action => 'wsdl'

  match 'dates/:year/:month/:day', :to => 'index#dates', :year => Time.now.year.to_s, :month => Time.now.month.to_s, :day => Time.now.day.to_s, :requirements => {:year => /\d{4}/, :day => /\d{1,2}/,:month => /\d{1,2}/}, :as => 'date_index'
  match 'index/:action/:letter', :to => 'index#lists', :letter => 'A', :as => 'index'

  match 'show/recently_viewed', :to => 'show#recently_viewed', :as => 'recently_viewed_talks'

  # No route matches {:controller=>"user", :action=>"create"} with match 'user/:action/:id', :to => 'user#show', :as => 'user'
  match 'login/:action', :to => 'login#index', :as => 'login'
  match '/reminder(/:action(/:id))', :to => 'reminder#index', :as => 'reminder'

  #map.with_options :controller => 'image', :action => 'show' do |image_controller|
  #end

  # Map the old embedded feeds
  # map.connect 'external/embed_feed.php', :controller => 'custom_view', :action => 'old_embed_feed'
  # map.connect 'directory/show_series.php', :controller => 'custom_view', :action => 'old_show_series'
  # map.connect 'external/feed.php', :controller => 'custom_view', :action => 'old_show_listing'

  match 'custom_view/:action', :to => 'custom_view#index', :as => 'custom_view'

  # match 'document/index', :to => 'document#index', :as => 'document_index'
  # match 'document/changes', :to => 'document#recent_changes'
  # match 'document/:name/:action', :controller => 'document', :action => 'show', :name => 'Home Page', :requirements => { :name => /[^\/]*/i }, :as => 'document'

  # Install the default route as the lowest priority.
  match ':controller(/:action(/:id))(.:format)'

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
