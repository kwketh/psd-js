NodeCanvas = require 'canvas'
Blender = require './blender'

rgba = (r, g, b, a) ->
  (r << 24 | g << 16 | b << 8 | a) >>> 0

toTruecolorAlphaBytes = (color) ->
  [color >>> 24, (color & 0x00ff0000) >> 16, (color & 0x0000ff00) >> 8, color & 0x000000ff]

module.exports = class Canvas

  constructor: (@node, width, height, @opts) ->
    @pixelData = if @node.isLayer() then (@node.get 'image').pixelData else []
    @width = +(width ||  @node.width)
    @height = +(height ||  @node.height)
    @top = @node.top
    @right = @node.right
    @bottom = @node.bottom
    @left = @node.left

    @opacity = +(@node.get 'opacity')
    # TODO
    @fillOpacity = 1.0

    @initializeCanvas()

  initializeCanvas: ->
    @canvas = new NodeCanvas(@width, @height)
    @ctx = @canvas.getContext '2d'
    @imageData = @ctx.createImageData(@width, @height)
    for i in [0...@imageData.data.length]
      @imageData.data[i] = @pixelData[i]
    @ctx.putImageData(@imageData, 0, 0)
    # TODO fill color

  paintTo: (base) ->
    @applyMasks()
    @applyClippingMask()
    @applyLayerStyles()
    @applyLayerOpacity()
    @composePixels(base)

  applyMasks: ->
#    for n in [@node].concat @node.ancestors()
#      continue unless n.isLayer() and n.layer.isRasterMask()
#      break if n.isGroup() and !n.passthruBlending()
      #TODO mask

  applyClippingMask: ->
    # TODO clipping mask

  applyLayerStyles: ->
    # TODO layer style

  applyLayerOpacity: ->
    # TODO layer opacity

  composePixels: (base) ->
    new Blender(@, base).compose()

#  fillColor: ->

  getPixel: (x, y) ->
    pos = (y * @width + x) * 4
    rgba(@imageData.data[pos], @imageData.data[pos+1], @imageData.data[pos+2], @imageData.data[pos+3])

  setPixels: (colors, x, y) ->
    height = colors.length
    width = colors[0].length
    imageData = @ctx.createImageData(width, height);
    for line, indexY in colors
      for pixel, indexX in line
        pos = (indexY * width + indexX) * 4
        rgbaArray = toTruecolorAlphaBytes pixel
        imageData.data[pos++] = rgbaArray[0]
        imageData.data[pos++] = rgbaArray[1]
        imageData.data[pos++] = rgbaArray[2]
        imageData.data[pos] = rgbaArray[3]

    @ctx.putImageData(imageData, x, y)
    @imageData = @ctx.getImageData(0, 0, @width, @height)
