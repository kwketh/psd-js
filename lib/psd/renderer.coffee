{Module} = require 'coffeescript-module'
Canvas = require './renderer/canvas'
PNG = require('pngjs').PNG

module.exports = class Renderer extends Module
  @includes require('./renderer/canvas_management.coffee')

  constructor: (node, @opts) ->
    @rootNode = node
    @renderHidden = opts.renderHidden

    # Our canvas always starts as the full document size because
    # all measurements are relative to this size. We can later crop
    # the image if needed.
    @width = @rootNode.width
    @height = @rootNode.height

    @canvasStack = []
    @nodeStack = [@rootNode]

    @rendered = false

  render: ->
    console.log "Beginning render process"

    # Create our base canvas
    activeNode = @activeNode()
    @createGroupCanvas(activeNode, activeNode.width, activeNode.height, { base: true })

    # Begin the rendering process
    @executePipeline()

    @rendered = true

  executePipeline: ->
    for child in @children().reverse()
      continue if @renderHidden is false and child.visible() is false
      if child.isGroup()
        @pushNode child
        if child.passthruBlending()
          @executePipeline()
        else
          @createGroupCanvas(child)
          @executePipeline()
          childCanvas = @popCanvas()
          childCanvas.paintTo @activeCanvas()

        @popNode()
        continue

      canvas = new Canvas(child, null, null, @opts)
      canvas.paintTo @activeCanvas()

  toPng: ->
    @render() unless @rendered
    canvas = @activeCanvas().canvas
    ctx = canvas.getContext '2d'
    imageData = ctx.getImageData(0, 0, @width, @height)
    png = new PNG(filterType: 4, width: @width, height: @height)
    png.data = imageData.data
    png

  children: ->
    activeNode = @activeNode()
    return [activeNode] if activeNode.isLayer()
    activeNode.children()

  pushNode: (node) -> @nodeStack.push node

  popNode: (node) -> @nodeStack.pop()

  activeNode: -> @nodeStack[@nodeStack.length - 1]
