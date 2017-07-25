match '/projects/:id/deliverables/index', :to => "deliverables#index", :via => [:get]
match '/projects/:id/deliverables/preview', :to => "deliverables#preview", :as => :preview_deliverable, :via => [:post, :put]
match '/projects/:id/deliverables', :to => "deliverables#create", :via => "post", :as => :create_deliverable
match '/projects/:id/deliverables/:deliverable_id/edit', :to => "deliverables#edit", :via => "get", :as => :edit_deliverable
match '/projects/:id/deliverables/:deliverable_id', :to => "deliverables#update", :via => "put", :as => :update_deliverable
match '/projects/:id/deliverables/:deliverable_id/bulk_assign_issues', :to => "deliverables#bulk_assign_issues", :via => "post", :as => :bulk_assign_issues_deliverable
match '/projects/:id/deliverables/:deliverable_id/issues', :to => "deliverables#issues", :as => :issues_deliverable, :via => [:get]
match '/projects/:id/deliverables/:deliverable_id', :to => "deliverables#destroy", :via => "delete", :as => :destroy_deliverable
