compose = require './compose'

module.exports = class Blender

  constructor: (@fg, @bg) ->
    @opacity = +@fg.opacity
    @fillOpacity = +@fg.fillOpacity
    @calculatedOpacity = @opacity * @fillOpacity

  compose: ->
    offsetX = @fg.left - @bg.left
    offsetY = @fg.top - @bg.top
    blendingMode = @fg.node.get('blendingMode')
    composeMethod = compose[blendingMode] || compose.normal

    colors = []
    for y in [0...@fg.height]
      baseY = y + offsetY
      continue if baseY < 0 or baseY >= @bg.height
      lineColors = []
      colors.push lineColors
      for x in [0...@fg.width]
        baseX = x + offsetX
        continue if baseX < 0 or baseX >= @bg.width
        color = composeMethod(@fg.getPixel(x, y), @bg.getPixel(baseX, baseY), @calculatedOpacity)
        lineColors.push color

    @bg.setPixels colors
