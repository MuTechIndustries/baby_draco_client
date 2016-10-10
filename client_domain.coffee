# Beef Up Backbone
# fullExtend behaves like how I wanted extend to
((Model) ->
	'use strict'
	# Additional extension layer for Models

	Model.fullExtend = (protoProps, staticProps) ->
		# Call default extend method
		extended = Model.extend.call(this, protoProps, staticProps)
		# Add a usable super method for better inheritance
		extended::_super = @prototype
		# Apply new or different defaults on top of the original
		if protoProps.defaults
			for k of @::defaults
				if !extended::defaults[k]
					extended::defaults[k] = @::defaults[k]
		extended

	return
) Backbone.Model

window.DracoClient = {}

DracoClient.Model = Backbone.Model.fullExtend
	draco_meta:
		dataSyncInProgress: true
	setInnerObjectKey: (path, key, value) ->
		obj = this.get(path)
		obj[key] = value
		this.set(path, obj)

DracoClient.addInstanceMethods = (model_instance) ->
	model_instance.save = (on_success) ->
		# Update
		if this.get('draco_meta').isPersistedInDomain
			$.ajax
				url: "#{this.dracoDomain.apiRoot}/#{this.get('draco_meta').tableName}/#{this.get('id')}"
				method: "put"
				data:
					payload: model_instance.dracoAttributes()
				success: (data) ->
					on_success(data) if on_success

		# Create
		else
			self = this
			$.ajax
				url: "#{this.dracoDomain.apiRoot}/#{this.get('draco_meta').tableName}"
				method: "post"
				data:
					payload: model_instance.dracoAttributes()
				success: (data) ->
					self.set('id', data.new_model_id)
					on_success(data) if on_success	

	model_instance.free = (on_success) ->
		self = this
		$.ajax
			url: "#{this.dracoDomain.apiRoot}/#{this.get('draco_meta').tableName}/free"
			method: "post"
			data:
				id: self.get('id')
			success: ( data ) ->
				self.set('status', 'free')
				on_success( data ) if on_success	

	model_instance.dracoAttributes = ->
		attrs = _.clone model_instance.attributes
		delete attrs["id"]
		delete attrs["draco_meta"]
		delete attrs["updated_at"]
		delete attrs["created_at"]
		attrs

DracoClient.Collection = Backbone.Collection.extend
	model: DracoClient.Model
	free: (identifiers) ->
		identifiers = [identifiers] unless _.isArray(identifiers)
		models = this.remove(identifiers)
		_.each models, (model) ->
			model.free()

DracoClient.restClientFactory = (api_root) ->
	self = 
		apiRoot: api_root
		restProtocols:
			find: (table_name, id, on_success) ->
				new_model_instance = new DracoClient.Model
					draco_meta:
						dataSyncInProgress: true
						tableName: table_name
						isPersistedInDomain: false
				new_model_instance.dracoDomain = self
				# Add instance methods
				DracoClient.addInstanceMethods(new_model_instance)
				# Load data from server and execute callback as well as update meta
				$.ajax
					url: "#{self.apiRoot}/#{table_name}/#{id}"
					success: (data) ->
						new_model_instance.set(data)
						new_model_instance.setInnerObjectKey('draco_meta', 'dataSyncInProgress', false)
						new_model_instance.setInnerObjectKey('draco_meta', 'isPersistedInDomain', true)
						on_success() if on_success
				new_model_instance

			new: (table_name) ->
				new_model_instance = new DracoClient.Model
					draco_meta:
						dataSyncInProgress: false
						tableName: table_name
						isPersistedInDomain: false
				new_model_instance.dracoDomain = self
				# Add instance methods
				DracoClient.addInstanceMethods(new_model_instance)
				new_model_instance

			where: (table_name, query_params, on_success) ->
				query_params ||= {}
				new_collection = new DracoClient.Collection
				new_collection.on "add", (model) ->
					DracoClient.addInstanceMethods(model)
				$.ajax
					url: "#{self.apiRoot}/#{table_name}"
					method: "get"
					success: (data) ->
						models = _.map data, (model_attrs) ->
							new_model_instance = new DracoClient.Model
								draco_meta:
									dataSyncInProgress: true
									tableName: table_name
									isPersistedInDomain: false
							new_model_instance.set(model_attrs)
							new_model_instance.dracoDomain = self
							new_model_instance
						new_collection.add(models)
						on_success() if on_success(data)
				new_collection

	self


