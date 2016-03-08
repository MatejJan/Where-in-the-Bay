class window.Function
  constructor: (@options) ->
    @options.enabled ?= false
    @options.desiredValue ?= 1
    @options.desiredWeight ?= 1

    $function = $('<div class="function">')

    $header = $("<label class='name'>")
    $function.append($header)

    $graph = $("<div class='graph-area'><canvas class='graph'></canvas></div>")
    $function.append($graph)
    $graph.hide() unless @options.enabled

    $canvas = $graph.find('canvas')
    @canvas = $canvas[0]
    @context = @canvas.getContext '2d'

    $canvas.click (event) =>
      width = $(event.target).width()
      height = $(event.target).height()

      @options.desiredValue = event.offsetX / width
      @options.desiredWeight = 1 - event.offsetY / height
      @updateGraph()

    $checkbox = $("<input type='checkbox' #{if @options.enabled then 'checked' else ''}/>")
    $checkbox.change (event) =>
      @options.enabled = $header.find('input').prop('checked')
      @updateGraph()
      if @options.enabled then $graph.show() else $graph.hide()

    $header.click (event) =>
      return unless event.shiftKey
      $('.functions input').prop('checked', false).change()
      $header.find('input').prop('checked', true).change()

    $header.append($checkbox)
    $header.append(@options.name)

    $('.functions').append($function)

    @updateGraph()

  updateGraph: ->
    @context.clearRect 0, 0, @canvas.width, @canvas.height

    @context.strokeStyle = 'white'

    @context.beginPath()
    @context.moveTo 0, @canvas.height * (1 - @options.desiredWeight * @functionAt 0)
    for i in [1..100]
      @context.lineTo i/100 * @canvas.width, @canvas.height * (1 - @options.desiredWeight * @functionAt i/100)

    @context.stroke()

  functionAt: (value) ->
    return 0 unless @options.enabled
    Math.pow(Math.sin((value - (1 + @options.desiredValue)) * Math.PI / 2), 2)

  valueAt: (x, y) ->
    @functionAt @options.data.valueAt x, y

  weight: ->
    return 0 unless @options.enabled
    @options.desiredWeight
