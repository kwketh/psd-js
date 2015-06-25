_ = require 'lodash'
Canvas = require './canvas.coffee'

module.exports =

  activeCanvas: -> @canvasStack[@canvasStack.length - 1]

  createGroupCanvas: (node, width, height, opts) ->
    @pushCanvas(new Canvas(node, width, height, _.merge(@opts, opts)))

  pushCanvas: (canvas) -> @canvasStack.push canvas

  popCanvas: -> @canvasStack.pop()

  stackInspect: -> @canvasStack.map (c) -> (c.node.name || ':root:').join('\n')
