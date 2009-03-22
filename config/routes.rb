ActionController::Routing::Routes.draw do |map|
  
  map.resources :users,       :only => [        :show                  ]
  map.resources :invites,     :only => [:index, :show,          :delete]
  map.resources :memberships, :only => [:index,        :create, :delete]
  
  map.resources :events,      :only => [:index, :show, :create, :delete]
  map.resources :groups,      :only => [:index, :show, :create, :delete]
  map.resources :projects,    :only => [:index, :show, :create, :delete]
  
end
