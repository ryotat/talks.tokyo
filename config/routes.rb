TalksTokyo::Application.routes.draw do
  resources :tickles

  root :to => 'search#index', :as => 'home'

  match 'search/' => 'search#results', :as => 'search'
  # match 'search/:search' => 'search#results', :search => nil
  match 'search/results' => 'search#results'

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  # map.connect ':controller/service.wsdl', :action => 'wsdl'

  match 'dates/:year/:month/:day', :to => 'index#dates', :year => Time.now.year.to_s, :month => Time.now.month.to_s, :day => Time.now.day.to_s, :requirements => {:year => /\d{4}/, :day => /\d{1,2}/,:month => /\d{1,2}/}, :as => 'date_index'
  match 'index/:action/:letter', :to => 'index#lists', :letter => 'A', :as => 'index'

  match 'show/:id', :to => 'show#index'
  match 'show/upcoming/:id', :to => 'show#index', :seconds_before_today => '0',  :reverse_order => true, :as => 'upcoming'
  match 'show/archive/:id', :to => 'show#index', :seconds_after_today => '0', :as => 'archive'
  match 'show/:action/:id', :to => 'show#index', :as => 'list'
  match 'list/:list_id/managers/:action', :to => 'list_user#index', :as => 'list_user'
  match 'list/:action(/:id)', :to => 'list#index', :as => 'list_details'

  match 'user/new', :to => 'user#new', :as => 'new_user'
  # No route matches {:controller=>"user", :action=>"create"} with match 'user/:action/:id', :to => 'user#show', :as => 'user'
  match 'user/:action(/:id)', :to => 'user#show', :as => 'user'
  match 'talk/:action(/:id)', :to => 'talk#index', :as => 'talk'
  match 'login/:action', :to => 'login#index', :as => 'login'
  match '/reminder(/:action(/:id))', :to => 'reminder#index', :as => 'reminder'
  match '/include/list/:action/:id', :to => 'list_list#create', :as => 'include_list'
  match '/include/talk/:action/:id', :to => 'list_talk#create', :as => 'include_talk'

  # Sort out the image controller
  scope '/image' do
    match '/image/:action/:id/image.png', :to => 'image#show', :as => 'connect'
    match '/image/:action/:id/image.png;:geometry', :to => 'image#show', :geometry => '128x128', :as => 'picture'
  end

  #map.with_options :controller => 'image', :action => 'show' do |image_controller|
  #end

  # Map the old embedded feeds
  # map.connect 'external/embed_feed.php', :controller => 'custom_view', :action => 'old_embed_feed'
  # map.connect 'directory/show_series.php', :controller => 'custom_view', :action => 'old_show_series'
  # map.connect 'external/feed.php', :controller => 'custom_view', :action => 'old_show_listing'
  
  match 'document/index', :to => 'document#index', :as => 'document_index'
  match 'document/changes', :to => 'document#recent_changes'
  match 'document/:name/:action', :controller => 'document', :action => 'show', :name => 'Home Page', :requirements => { :name => /[^\/]*/i }, :as => 'document'

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
