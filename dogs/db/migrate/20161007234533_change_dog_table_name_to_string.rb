class ChangeDogTableNameToString < ActiveRecord::Migration[5.0]
	def change
		change_column :dogs, :name, :text
	end
end
