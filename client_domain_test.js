(function() {
  var aura, draco_model_instance, restClient, sparky;

  draco_model_instance = new DracoClient.Model;

  Assert.assert(draco_model_instance.draco_meta, "not full extension couldn't apply to instanciations");

  Assert.assert(draco_model_instance.draco_meta.dataSyncInProgress, "Should initialize to true");

  restClient = DracoClient.restClientFactory("http://localhost:3000");

  Assert.assert_eq(restClient.apiRoot, "http://localhost:3000", "Did not set apiRoot correctly");

  Assert.newThread();

  sparky = restClient.restProtocols.find('dogs', 1, function() {
    Assert.assert_eq(sparky.get('id'), 1);
    Assert.assert_eq(sparky.get('name'), 'Sparky');
    Assert.assert_eq(sparky.get('age'), 4);
    Assert.assert(!sparky.get('draco_meta').dataSyncInProgress, "did not set dataSyncInProgress back to false");
    Assert.assert(sparky.get('draco_meta').isPersistedInDomain, "did not set isPersistedInDomain to true");
    Assert.newThread();
    sparky.save(function(data) {
      Assert.assert_eq(data.status, "success", "Did not update correctly");
      return Assert.finishTreadLogResultsIfSuiteIsComplete();
    });
    return Assert.finishTreadLogResultsIfSuiteIsComplete();
  });

  Assert.assert(sparky.get('draco_meta').dataSyncInProgress, "did not set dataSyncInProgress to true");

  Assert.assert(!sparky.get('draco_meta').isPersistedInDomain, "did not set isPersistedInDomain to false");

  Assert.assert_eq(sparky.get('draco_meta').tableName, "dogs", "did not set table name");

  Assert.assert(!sparky.dracoAttributes()["draco_meta"], "Did not remove proper keys for dracoAttributes");

  Assert.assert_eq(sparky.dracoDomain.apiRoot, restClient.apiRoot, "Did not set dracoDomain on instantiation");

  aura = restClient.restProtocols["new"]('dogs');

  aura.set('name', 'Aura');

  aura.set('age', 2);

  Assert.assert(!aura.get('id'), "Id is not blank it should be");

  Assert.newThread();

  aura.save(function() {
    Assert.assert(aura.get('id'), "Id is blank it should not be");
    Assert.newThread();
    return aura.free(function() {
      Assert.assert_eq(aura.get('status'), 'free', "Aura was not set free. She is in another castle.");
      Assert.finishTreadLogResultsIfSuiteIsComplete();
      Assert.newThread();
      window.dog_collection = restClient.restProtocols.where('dogs', {}, function(data) {
        Assert.assert_eq(dog_collection.length, 3, "Did not fetch all dogs");
        Assert.assert_eq(dog_collection.pluck('name')[2], "Barkiller", "Did not fetch dogs correctly");
        Assert.assert(dog_collection.at(0).free, "Did not apply dracoInstanceMethods to new collection");
        return Assert.finishTreadLogResultsIfSuiteIsComplete();
      });
      Assert.assert_eq(dog_collection.length, 0, "Dog collection is not empty right after init");
      return Assert.finishTreadLogResultsIfSuiteIsComplete();
    });
  });

  Assert.finishTreadLogResultsIfSuiteIsComplete();

}).call(this);

