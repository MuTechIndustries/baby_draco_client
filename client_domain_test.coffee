# DracoClient 

# Model
# Extends from Backbone.Model
# Draco Meta
draco_model_instance = new DracoClient.Model
Assert.assert draco_model_instance.draco_meta, "not full extension couldn't apply to instanciations"
Assert.assert draco_model_instance.draco_meta.dataSyncInProgress, "Should initialize to true"

# RestClientFactory to restClient instance
restClient = DracoClient.restClientFactory("http://localhost:3000")
Assert.assert_eq restClient.apiRoot, "http://localhost:3000", "Did not set apiRoot correctly"

# use restClient to fetch one of table_name
Assert.newThread()
sparky = restClient.restProtocols.find 'dogs', 1, ->
	Assert.assert_eq(sparky.get('id'), 1)
	Assert.assert_eq(sparky.get('name'), 'Sparky')
	Assert.assert_eq(sparky.get('age'), 4)
	# After data update dataSyncInProgress should be true
	Assert.assert not sparky.get('draco_meta').dataSyncInProgress, "did not set dataSyncInProgress back to false"
	# Should set isPersistedInDomain to true once sync is complete
	Assert.assert sparky.get('draco_meta').isPersistedInDomain, "did not set isPersistedInDomain to true"	
	# Test instance rest actions
	Assert.newThread()
	sparky.save (data) ->
		Assert.assert_eq data.status, "success", "Did not update correctly"
		Assert.finishTreadLogResultsIfSuiteIsComplete()
	# Register new Assert Thread
	Assert.finishTreadLogResultsIfSuiteIsComplete()

# right after before data is recieved it should have dataSyncInProgress in draco_meta set to false
# this should always execute before the callback above is fired
# use get for draco_meta to ensure updated data an object is returned from there
Assert.assert sparky.get('draco_meta').dataSyncInProgress, "did not set dataSyncInProgress to true"
# should be instantiated with is persisted by domain set to false
Assert.assert not sparky.get('draco_meta').isPersistedInDomain, "did not set isPersistedInDomain to false"
# Should be assigned a table name
Assert.assert_eq sparky.get('draco_meta').tableName, "dogs", "did not set table name"
# method dracoAttributes should remove unwanted attributes for client to server and viceversa comunications
Assert.assert not sparky.dracoAttributes()["draco_meta"], "Did not remove proper keys for dracoAttributes"
# should set dracoDomain on instantiation
Assert.assert_eq sparky.dracoDomain.apiRoot, restClient.apiRoot, "Did not set dracoDomain on instantiation"

# should create when not persisted yet
aura = restClient.restProtocols.new 'dogs'
aura.set('name', 'Aura')
aura.set('age', 2)
# Should have no id before persistance
Assert.assert not aura.get('id'), "Id is not blank it should be"
Assert.newThread()
aura.save ->
	# Should update id after save
	Assert.assert aura.get('id'), "Id is blank it should not be"

	# should free from server
	Assert.newThread()
	aura.free ->
		Assert.assert_eq aura.get('status'), 'free', "Aura was not set free. She is in another castle."
		Assert.finishTreadLogResultsIfSuiteIsComplete()

		# use restClient to fetch a collection of a table_name
		# empty qparams should result in an all query
		Assert.newThread()
		window.dog_collection = restClient.restProtocols.where 'dogs', {}, (data) ->
			# after callback dog_collection should be populated with models from query
			Assert.assert_eq dog_collection.length, 3, "Did not fetch all dogs"
			Assert.assert_eq dog_collection.pluck('name')[2], "Barkiller", "Did not fetch dogs correctly"
			# collection instances should have dracoInstanceMethods
			Assert.assert dog_collection.at(0).free, "Did not apply dracoInstanceMethods to new collection"
			Assert.finishTreadLogResultsIfSuiteIsComplete()
			# collections shoule have a free function that both calls free to server and frees from client collection
			# Testing very complicated for this framework, will improve callbacks later for now tested by hand in console
		# dog_collection should be an empty collection while awaiting data sync
		Assert.assert_eq dog_collection.length, 0, "Dog collection is not empty right after init"
		Assert.finishTreadLogResultsIfSuiteIsComplete()

# Should be able to execute where queries
# TODO: accepts an array of query object {column_name: val, operator: val, value: val}
# will contruct where clause on server end point
# E.X. Model.where([{column_name: 'age', operator: "<", value: 14}])
# server result Dog::where("age < ?", 14)
# Should build from multiple
# Should filter operators to only exceptable no SQLInjection < > <= >= != = etc...

Assert.finishTreadLogResultsIfSuiteIsComplete()