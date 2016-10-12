Exec = null
Fs = null

module.exports =
class Runner

  constructor: (@solutionPath) ->

  run: (input, output, callback) ->
    # Lazy dependency loading for start-up performance improving
    Exec ?= require('child_process').exec
    Fs ?= require('fs')

    # Open the input file
    inputStream = fs.createReadStream(input)

    # Run the solution file
    pythonPath = atom.config.get 'iotest-runner.pythonPath'
    cmd = [pythonPath, @solutionPath].join(" ")
    process = Exec cmd, (error, stdout, stderr) ->
      if stderr
        callback("fail", stderr)
      else
        expected = fs.readFileSync output
        if expected != actual
          callback("no", actual)
        else
          callback("yes")
    inputStream.pipe(process.stdin)
