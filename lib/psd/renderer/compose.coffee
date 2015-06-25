module.exports =

  normal: (fg, bg, opacity) ->
    return applyOpacity(fg, opacity) if isFullyTransparent(bg)
    return bg if isFullyTransparent(fg)
    fg
    alpha = calculateAlphas(fg, bg, opacity)
    newR = blendChannel(r(bg), r(fg), alpha.mixAlpha)
    newG = blendChannel(g(bg), g(fg), alpha.mixAlpha)
    newB = blendChannel(b(bg), b(fg), alpha.mixAlpha)

    rgba(newR, newG, newB, alpha.dstAlpha)

r = (value) ->
  (value >>> 24) & 0x000000ff

g = (value) ->
  (value & 0x00ff0000) >> 16

b = (value) ->
  (value & 0x0000ff00) >> 8

a = (value) ->
  value & 0x000000ff

rgba = (r, g, b, a) ->
  (r << 24 | g << 16 | b << 8 | a) >>> 0

applyOpacity = (color, opacity) ->
  (color >>> 8) * 0x100 + ((color & 0x000000ff) * opacity / 255)

isFullyTransparent = (color) ->
  a(color) is 0x00000000

calculateAlphas = (fg, bg, opacity) ->
  srcAlpha = a(fg) * opacity >> 8
  dstAlpha = a(bg)

  mixAlpha = (srcAlpha << 8) / (srcAlpha + ((256 - srcAlpha) * dstAlpha >> 8))
  dstAlpha = dstAlpha + ((256 - dstAlpha) * srcAlpha >> 8)

  mixAlpha: mixAlpha
  dstAlpha: dstAlpha

blendChannel = (bg, fg, alpha) ->
  ((bg << 8) + (fg - bg) * alpha) >> 8
