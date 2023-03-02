{CompositeDisposable} = require 'atom'

Model = require './Models/IOTestRunnerModel'
View = require './Views/IOTestRunnerView'
ViewModel = require './Controllers/IOTestRunnerViewModel'
VueBinder = require './Controllers/IOTestRunnerVueBinder'

module.exports = IOTestRunnerPackage =
  ViewUri: "iotestrunner://"
  subscriptions: null

  config:
    relativeTestsDirectory:
      title: 'Tests Directory'
      description: "Relative path to the tests directory from the script path"
      type: 'string'
      default: ''
    timeThreshold:
      title: 'Language Time Threshold'
      description: "The maximum execution time allowed in milliseconds"
      type: 'number'
      default: 10000
      minimum: 0
    pythonPath:
      title: 'Python Path'
      description: "Path to the python executable"
      type: 'string'
      default: ''
    splitDirection:
      title: 'Split Direction'
      description: 'The direction to split the test panel'
      type: 'string'
      default: 'bottom'
      enum: ['center', 'left', 'right', 'bottom']

  activate: (state) ->
    # Create a new CompositeDisposable for registered actions
    @subscriptions = new CompositeDisposable

    # Create a new opener to run files.
    # If the URI was already open, it won't open twice.
    @subscriptions.add atom.workspace.addOpener (uri) =>
      return @open uri.slice(@ViewUri.length) if uri.startsWith(@ViewUri)

    # Register command that open the view for this file.
    @subscriptions.add atom.commands.add(
      'atom-workspace',
      'iotest-runner:open': =>
        filepath = atom.workspace.getActiveTextEditor()?.getPath()
        if filepath?
          atom.workspace.open(@ViewUri + filepath)
    )

  deactivate: ->
    @subscriptions.dispose()

  serialize: ->

  open: (file) ->
    # Initialize the model and the view
    model = new Model
    view = new View file
    viewModel = new ViewModel file, model, view
    binder = new VueBinder view, viewModel

    # Return the view to show
    return binder.view