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
    return "IOTestRunner"

  getURI: ->
    return "atom://iotestrunner/" + @solutionPath

  getIconName: ->
    return "puzzle"

  getDefaultLocation: ->
    return atom.config.get 'iotest-runner.splitDirection'

  destroy: ->
    @element.remove()

  getElement: ->
    return @element