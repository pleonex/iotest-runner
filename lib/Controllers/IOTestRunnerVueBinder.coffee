{allowUnsafeNewFunction} = require 'loophole'
Vue = require 'vue'

module.exports =
class LogSharkVueBinder
  constructor: (@view, @model) ->
    @vue = allowUnsafeNewFunction =>
      new Vue
        el: @view.element
        data: @model
        methods:
          run: (test) ->
            @$data.onRun(test)
          runAll: ->
            @$data.onRunAll()
