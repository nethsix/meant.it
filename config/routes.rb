MeantIt::Application.routes.draw do

  get "/shops/:id" => "shops#show"
  post "/payments/ipn_pp_20111224" => "payments#ipn"
  get "/payments/pay/invoice_no/:invoice_no" => "payments#pay"
  get "/payments/invoice_no/:invoice_no" => "payments#show"
  get "/payments/cancel/invoice_no/:invoice_no" => "payments#cancel"

  resources :payments

#  get "sessions/new"
  get "log_in" => "sessions#new", :as => "log_in"  
  get "log_out" => "sessions#destroy", :as => "log_out"
  get "verify_captcha" => "sessions#verify_captcha", :as => "verify_captcha"
  get "manage" => "sessions#manage", :as => "manage"
  get "resend_confirmation" => "sessions#resend_confirmation", :as => "resend_confirmation"
  get "send_liker_emails" => "sessions#send_liker_emails"
#20111108  get "bill" => "sessions#bill", :as => "bill"
  get "bill" => "sessions#bill_2", :as => "bill_2"
  get "bills/error" => "sessions#bills_error"

  devise_for :users, :controllers => { :confirmations => "meant_it_confirmations" }

  resources :sessions

  resources :pii_property_sets

  resources :inbound_email_logs

  resources :yes_emails

  resources :meant_it_mood_tag_rels

  resources :entity_data

  resources :inbound_emails

  resources :end_point_tag_rels

  resources :tags

  resources :obj_rels

  resources :meant_it_rels do
    collection do
      get 'show_out_by_pii'
      get 'count_in_mirs'
      get 'show_in_by_pii'
      get 'show_out_by_endpoint_nick/:nick/(:message_type)', :action => 'show_out_by_endpoint_nick'
      get 'show_in_by_endpoint_nick/:nick/(:message_type)', :action => 'show_in_by_endpoint_nick'
      get 'show_out_by_endpoint_id/:id/(:message_type)', :action => 'show_out_by_endpoint_id'
      get 'show_in_by_endpoint_id/:id/(:message_type)', :action => 'show_in_by_endpoint_id'
      get 'show_by_endpoint_endpoint_nick/:nick1/:nick2/(:message_type)', :action => 'show_by_endpoint_endpoint_nick'
      get 'show_by_pii_pii' 
      get 'show_by_pii_endpoint_nick'
      get 'show_by_endpoint_nick_pii'
      get 'show_by_message_type'
    end
  end

  resources :entity_end_point_rels

  resources :end_points do
    collection do
      get 'show_by_nick/:nick', :action => "show_by_nick"
      get 'find_by_nick_and_creator_endpoint_id'
      get 'show_by_nick_and_creator_endpoint_id'
      get 'find_by_tags'
      get 'show_by_tags'
      get "show_by_id/:id", :action => "show_by_id"
      get "show_by_ids"
    end
  end

  resources :entities

  resources :piis do
    collection do
      get 'find_by_pii_value'
      get 'find_by_pii_value_debug'
      get 'show_by_pii_value'
      get 'show_by_pii_value_debug'
      get 'show_by_message_type_uniq_sender_count'
      get 'show_like_pii_value_uniq_sender_count_after_last_bill'
    end
  end

  resources :people

  get "home/index"

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
  # root :to => "welcome#index"
  root :to => "home#index"
  match "/why" => "home#why"
  match "/message_types" => "home#message_types"
  match "/learn_find" => "home#learn_find"
  match "/learn_send" => "home#learn_send"
  match "/tutorial_1" => "home#tutorial_1"
  match "/group.html" => "home#group"
  # 20111212: Take care of new piis where email_bill_entry is immediately
  # created
  # match "/group_2.html" => "home#group_2"
  # 20111213: For old piis whose email_bill_entry is NOT created upon
  # inbound_email
  match "/group_old.html" => "home#group_old"
  match "/group_diy.html" => "home#group_diy"
  match "/like.html" => "home#like"
  match "/platform.html" => "home#platform"
  match "/apis.html" => "home#apis"
  match "/policy.html" => "home#policy"
  match "/campaigns/:name" => "home#campaigns"
  match "/campaigns/:predir/:name" => "home#campaigns"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'

#  match '/receive_email' => 'emails#receive_email'
  match "/receive_email" => ReceiveEmail

  match "/find_any" => FindAny.action(:index)

  match "/inbound_emails_200" => "inbound_emails#create", :defaults => { :format => 'xml' }
  match "/send_inbound_emails" => "inbound_emails#create"
#  match "/send_email" => SendEmail.action(:index)

#  root :to => "people#index"
#  root :to => "home#meant_it"

end
