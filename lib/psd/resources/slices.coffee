Descriptor = require '../descriptor.coffee'

module.exports = class Slices
  id: 1050
  name: 'slices'

  constructor: (@resource) ->
    @file = @resource.file

  parse: () ->
    @version = @file.readInt()
    switch @version
      when 6 then @parseLegacy()
      when 7, 8
        descriptorVersion = @file.readInt()
        @data = new Descriptor(@file).parse()

    @normalize_data()

  export: ->
    @data

  parseLegacy: ->
    @data = {}

    @data.bounds =
      top: @file.readInt()
      left: @file.readInt()
      bottom: @file.readInt()
      right: @file.readInt()

    @data.name = @file.readUnicodeString()

    @data.slices = []
    slicesCount = @file.readInt()

    for i in [1..slicesCount]
        
      slice = {}
        
      slice.id = @file.readInt()
      slice.groupId = @file.readInt()
      slice.origin = @file.readInt()

      slice.associatedLayerId = if slice.origin is 1 then @file.readInt() else null
        
      slice.name = @file.readUnicodeString()
      slice.type = @file.readInt()
        
      slice.bounds =
        left: @file.readInt()
        top: @file.readInt()
        right: @file.readInt()
        bottom: @file.readInt()
        
      slice.url = @file.readUnicodeString()
      slice.target = @file.readUnicodeString()
      slice.message = @file.readUnicodeString()
      slice.alt = @file.readUnicodeString()

      slice.cellTextIsHtml = @file.readBoolean()
      slice.cellText = @file.readUnicodeString()

      slice.horizontalAlignment = @file.readInt()
      slice.verticalAlignment = @file.readInt()

      slice.color = @file.readInt()

      @data.slices.push slice

  normalize_data: ->
    return if @version is 6

    data = {}
    data.bounds =
      top: @data.bounds['Top ']
      left: @data.bounds['Left']
      bottom: @data.bounds['Btom']
      right: @data.bounds['Rght']

    data.name = @data['baseName']

    data.slices = @data['slices'].map (slice) ->
      id: slice['sliceID']
      groupId: slice['groupID']
      origin: slice['origin']
      associatedLayerId: null
      name: ''
      type: slice['Type']
      bounds:
        left: slice['bounds']['Left']
        top: slice['bounds']['Top ']
        right: slice['bounds']['Rght']
        bottom: slice['bounds']['Btom']
      url: slice['url']
      target: ''
      message: slice['Msge']
      alt: slice['altTag']
      cellTextIsHtml: slice['cellTextIsHTML']
      cellText: slice['cellText']
      horizontalAlignment: slice['horzAlign']
      verticalAlignment: slice['vertAlign']
      color: null
      outset:
        top: slice['topOutset']
        left: slice['leftOutset']
        bottom: slice['bottomOutset']
        right: slice['rightOutset']
        
    @data = data


