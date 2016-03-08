class window.Gradient
  constructor: (filename) ->
    console.log "Loading gradient", filename
    image = new Image()

    image.onload = =>
      @size = image.width
      canvas = document.createElement 'canvas'
      canvas.width = @size
      canvas.height = 1
      canvas.getContext('2d').drawImage image, 0, 0, @size, 1
      imageData = canvas.getContext('2d').getImageData(0, 0, @size, 1).data

      @data = []
      for x in [0...@size]
        r = imageData[x * 4] / 255
        g = imageData[x * 4 + 1] / 255
        b = imageData[x * 4 + 2] / 255
        @data[x] = new THREE.Color r, g, b

      @loaded = true

    image.src = filename

  colorAt: (percentage) ->
    return null unless @loaded
    x = Math.floor(percentage * @size)

    @data[x]
