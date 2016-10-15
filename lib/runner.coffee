exec = null
fs = null
os = null

module.exports =
class Runner

  constructor: (@solutionPath) ->
    @solutionPath = "\"#{@solutionPath}\""
    @runningInputs = {}

  stop: (input) ->
    if not @runningInputs[input]
      return
    @runningInputs[input].kill()

  run: (input, output, callback) ->
    if @runningInputs[input]
      atom.notifications.addInfo("\"#{input}\" already running, stop it first")
      return

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

    threshold = atom.config.get 'iotest-runner.timeThreshold'
    startTime = process.hrtime()
    proc = exec cmd, (error, stdout, stderr) =>
      @runningInputs[input] = null
      endTime = process.hrtime(startTime)
      elapsed = endTime[0] * 1000 + endTime[1] / 1000000  # to ms
      if stderr
        callback("fail", stderr)
      else if threshold > 0 and elapsed > threshold
        callback("timeout")
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
    @runningInputs[input] = proc
    setTimeout(
      () -> proc.kill(),
      threshold)
    inputStream.pipe(proc.stdin)
