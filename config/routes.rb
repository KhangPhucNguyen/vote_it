FeedMeBack::Application.routes.draw do
    match '/signin' => 'session#signin'
    match '/signout' => 'session#signout'
    match '/signup' => 'session#signup'

    match '/poll_set/create' => 'poll_set#create'
    match '/poll_set/edit/:id' => 'poll_set#edit'
    match '/poll_set/update' => 'poll_set#update'
    match '/poll_set/admin' => 'poll_set#admin'
    match '/poll_set/list' => 'poll_set#list'
    match '/poll_set/view/:poll_set_id' => 'poll_set#view'
    match '/poll_set/overview/:poll_set_id' => 'poll_set#overview'
    match '/poll_set/delete/:poll_set_id' => 'poll_set#delete'
    match '/poll_set/deactivate/:poll_set_id' => 'poll_set#deactivate'
    match '/poll_set/activate/:poll_set_id' => 'poll_set#activate'

    match '/poll/new' => 'poll#new'
    match '/poll/new/:poll_set_id' => 'poll#new'
    match '/poll/create' => 'poll#create'
    match '/poll/edit/:id' => 'poll#edit'
    match '/poll/update' => 'poll#update'
    match '/poll/admin' => 'poll#admin'
    match '/poll/answer' => 'poll#answer'
    match '/poll/list' => 'poll#list'
    match '/poll/view/:poll_id' => 'poll#view'
    match '/poll/overview/:poll_id' => 'poll#overview'
    match '/poll/delete/:poll_id' => 'poll#delete'
    match '/poll/deactivate/:poll_id' => 'poll#deactivate'
    match '/poll/activate/:poll_id' => 'poll#activate'

    root :to => 'poll_set#list'
end
