{allowUnsafeNewFunction} = require 'loophole'
Vue = require 'vue'

module.exports =
class LogSharkVueBinder
  constructor: (@view, @model) ->
    @vue = allowUnsafeNewFunction =>
      new Vue
        el: @view.element
        data: @model
