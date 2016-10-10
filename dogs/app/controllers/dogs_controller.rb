class DogsController < ApplicationController
	def index
		render json: Dog.all
	end
	def show
		render json: Dog::find(params[:id])
	end
	def create
		response = Hash.new
		dog = Dog::new(dog_params)
		if dog.save
			response[:status] = :success
			response[:new_model_id] = dog.id
		else
			response[:status] = :failure
			response[:errors] = dog.errors
		end
		render json: response
	end
	def update
		response = Hash.new
		dog = Dog::find(params[:id])
		if dog.update_attributes(dog_params)
			response[:status] = :success
		else
			response[:status] = :failure
			response[:errors] = dog.errors
		end
		render json: response
	end

	def free
		@free_dog = Dog::find(params[:id])
		Dog::free( @free_dog )
		@free_dog = "1/0" #infinity
		render json: {status: "success"}
		# Go on your free now...
	end

	private
	def dog_params
		params.require(:payload).permit(:name, :age)
	end
end
