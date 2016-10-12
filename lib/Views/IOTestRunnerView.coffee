fs = require 'fs'
path = require 'path'

module.exports =
class IOTestRunnerView
  constructor: (@solutionPath) ->
    @element = document.createElement('div')
    @element.classList.add('iotestrunner-view')
    @element.innerHTML = fs.readFileSync(
      path.join(__dirname, 'IOTestRunnerView.html'))

  serialize: ->

  getTitle: ->
    return "[IOTestRunner] " + path.basename @solutionPath

  getURI: ->
    return "iotestrunner://" + @solutionPath

  getIconName: ->
    return "puzzle"

  destroy: ->
    @element.remove()

  getElement: ->
    return @element