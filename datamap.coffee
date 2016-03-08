class window.DataMap
  constructor: (filename) ->
    console.log "Loading data map", filename
    image = new Image()

    image.onload = =>
      @size = image.width
      canvas = document.createElement 'canvas'
      canvas.width = @size
      canvas.height = @size
      canvas.getContext('2d').drawImage image, 0, 0, @size, @size
      imageData = canvas.getContext('2d').getImageData(0, 0, @size, @size).data

      @data = []
      for x in [0...@size]
        @data[x] = []
        for y in [0...@size]
          @data[x][y] = imageData[(y * @size + x) * 4] / 255

      @loaded = true

    image.src = filename

  valueAt: (xPercentage, yPercentage) ->
    return 0 unless @loaded
    x = Math.floor(xPercentage * @size)
    y = Math.floor(yPercentage * @size)

    @data[x][y]
