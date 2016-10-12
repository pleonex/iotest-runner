Runner = require '../runner.coffee'
Vue = null

module.exports =
class IOTestRunnerViewModel
  constructor: (@solutionPath, @model, @view) ->
    @runner = new Runner @solutionPath
    # TODO: Fin tests

  onRun: (input, output) ->
    # TODO: Run

  onRnAll: ->
    # TODO: Run all
