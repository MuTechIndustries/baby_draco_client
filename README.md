# Baby Draco Client
## Scope
Baby Draco Client is a young prototype of what will eventually be a Rich Javascript Client framework that comunicates with our DRACO backend. This prototype is concerned with fetching data from a Rails App that represents DRACO though DRACO is still in development. It acts as a go between, between a Rails API application and Backbone, it provides REST functionality to Backbone by bypassing their built in methods to create a cleaner DSL.
## Dogs
Dogs is a rails app that provides a very simple API for testing.
## Assert
A very light assert javascript library for testing
## Client Domain
The library that acomplishes the scope of this project
## Client Domain Test
Uses assert and dogs to test client domain
## Todo
1. Finish where
  1. on_success is not called correctly and the if exist statement is incorect ( see upwork_demo for edit )
2. Refine assert to handle asyncranis respones better
3. Refine library
4. Finish DRACO
5. Create DRACO client
