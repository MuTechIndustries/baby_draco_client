(function() {
  window.Assert = {};

  Assert.number_of_assertions = 0;

  Assert.failed_assertions = 0;

  Assert.pendingThreads = 1;

  Assert.newThread = function() {
    return Assert.pendingThreads += 1;
  };

  Assert.assert = function(condition, message) {
    Assert.number_of_assertions += 1;
    if (!condition) {
      Assert.failed_assertions += 1;
      return console.log("Assert failed: " + message + " | condition is " + condition);
    }
  };

  Assert.assert_eq = function(result, expected, message) {
    Assert.number_of_assertions += 1;
    if (!(expected === result)) {
      Assert.failed_assertions += 1;
      console.log("Assert failed: " + message);
      console.log("Expected: " + expected);
      return console.log("Actual: " + result);
    }
  };

  Assert.finishTreadLogResultsIfSuiteIsComplete = function() {
    var successful_assertions;
    Assert.pendingThreads -= 1;
    if (Assert.pendingThreads === 0) {
      successful_assertions = Assert.number_of_assertions - Assert.failed_assertions;
      console.log;
      console.log("--------------------------------------------------------");
      console.log("Testing Results:");
      console.log("Number of asserts: " + Assert.number_of_assertions);
      console.log("Passed: " + successful_assertions);
      console.log("Failed: " + Assert.failed_assertions);
      console.log("--------------------------------------------------------");
      return console.log;
    }
  };

}).call(this);

