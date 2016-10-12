exec = null
fs = null
os = null

module.exports =
class Runner

  constructor: (@solutionPath) ->
    @solutionPath = "\"#{@solutionPath}\""

  run: (input, output, callback) ->
    # Lazy dependency loading for start-up performance improving
    exec ?= require('child_process').exec
    fs ?= require('fs')
    os ?= require('os')

    # Open the input file
    inputStream = fs.createReadStream(input)

    # Run the solution file
    pythonPath = atom.config.get 'iotest-runner.pythonPath'
    pythonPath = "python" if not pythonPath
    cmd = [pythonPath, @solutionPath].join(" ")

    process = exec cmd, (error, stdout, stderr) ->
      if stderr
        callback("fail", stderr)
      else
        fs.readFile output, (err, expected) ->
          if err
            console.error(err)
            return

          expected = expected.toString()
          expected += '\n' if expected[expected.length - 1] != '\n'
          expected = expected.replace(/\r/g, "").replace(/\n/g, os.EOL)
          if expected != stdout
            msg = "Output:\n#{stdout}is different to expected\n#{expected}"
            callback("incorrect", msg)
          else
            callback("valid")
    inputStream.pipe(process.stdin)
