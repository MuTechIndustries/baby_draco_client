Rails.application.routes.draw do
	resources :dogs, except: [:destroy] do
		collection do
			post 'free'
		end
	end
end
