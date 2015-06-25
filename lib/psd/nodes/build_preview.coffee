Renderer = require '../renderer.coffee'

module.exports =
  renderer: (opts) -> new Renderer(@, opts)
  toPng: ->
    @png = @png || @renderer({ renderHidden: @isLayer() }).toPng()
  saveAsPng: (output) ->
    @toPng.save(output)
