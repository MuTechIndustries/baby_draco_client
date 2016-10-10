class Dog < ApplicationRecord
	validates_presence_of :name

	class << self
		def free( free_dog )
			free_dog.destroy
			free_dog = "1/0" # infinity
		end
	end
end
