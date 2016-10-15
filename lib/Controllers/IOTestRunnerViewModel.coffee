Runner = null
path = null
fs = null

module.exports =
class IOTestRunnerViewModel
  constructor: (solutionPath, @model, @view) ->
    # Lazy requirements for performance
    fs ?= require 'fs'
    path ?= require 'path'
    Runner ?= require '../runner.coffee'

    @runner = new Runner solutionPath

    @model.name =  path.basename solutionPath
    @model.solutionPath = solutionPath

    relativeTestsDir = atom.config.get 'iotest-runner.relativeTestsDirectory'
    @model.testsDir = path.join(path.dirname(solutionPath), relativeTestsDir)
    @findTests()

  findTests: ->
    inputRegex = /input(\d+).txt/
    fs.readdir @model.testsDir, (err, files) =>
      if err
        console.error(err)
        return

      for f in files
        match = f.match(inputRegex)
        continue if not match
        f = path.join @model.testsDir, f
        test =
          status: "UNKNOWN"
          statusMode: ''
          inputPath: f
          inputName: path.basename(f)
          outputPath: path.join(path.dirname(f), "output" + match[1] + ".txt")
          outputName: "output" + match[1] + ".txt"
        @model.tests.push test

  onRun: (test) ->
    test.status = "RUNNING"
    test.statusMode = "-info"
    @runner.run test.inputPath, test.outputPath, (result, msg) =>
      if result == "fail"
        test.status = 'BUG'
        test.statusMode = '-error'
        atom.notifications.addFatalError(
          "Bug in #{@model.name} for #{test.inputName}!!!",
          {'detail': msg, 'dismissable': true})
      else if result == "incorrect"
        test.status = 'FAILED'
        test.statusMode = '-error'
        atom.notifications.addError(
          "Test #{test.inputName} for #{@model.name} failed!",
          {'detail': msg, 'dismissable': true})
      else if result == "timeout"
        test.status = 'TIMEOUT'
        test.statusMode = '-error'
        atom.notifications.addError(
          "Test #{test.inputName} for #{@model.name} timed out!")
      else if result == "memory_exceeded"
        test.status = 'MEMORY EXCEEDED'
        test.statusMode = '-error'
        atom.notifications.addError(
          "Test #{test.inputName} for #{@model.name} exceeded memory!")
      else if result == "valid"
        test.status = 'PASSED'
        test.statusMode = '-success'
        atom.notifications.addSuccess(
          "Tests for #{@model.name} passed!")
      @updateProgress()

  onRunAll: ->
    for t in @model.tests
      @onRun(t)

  updateProgress: ->
    if @model.tests.length == 0
      return

    passed = @model.tests.map((t) -> if t.status == 'PASSED' then 1 else 0)
      .reduce((sum, v) -> sum + v)
    @model.progress = passed * 100 / @model.tests.length
