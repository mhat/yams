ActionController::Routing::Routes.draw do |map|
  
  map.resources :users,       :only => [:index, :show                   ]
  map.resources :invites,     :only => [:index, :show, :create, :destroy]
  map.resources :memberships, :only => [:index,        :create, :destroy]
  
  map.resources :events,      :only => [:index, :show, :create, :destroy]
  map.resources :groups,      :only => [:index, :show, :create, :destroy]
  map.resources :projects,    :only => [:index, :show, :create, :destroy]
  
end
