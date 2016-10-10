namespace :seed do
	desc "Populare with data for DracoClient tests"
	task dogs: :environment do
		Dog::destroy_all
		DatabaseCleaner.clean_with(:truncation)

		[
			{name: "Sparky", age: 4},
			{name: "Pancho", age: 17},
			{name: "Barkiller", age: 14},
		].each do |attrs|
			Dog::create(attrs)
		end

	end

end
