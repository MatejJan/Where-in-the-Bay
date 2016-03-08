class window.DataGrid
  constructor: (scene, terrain) ->
    @size = 70

    root = new THREE.Object3D()
    scene.add root
    scale = terrain.size / @size
    root.scale.set scale, terrain.size * 0.2, scale
    root.position.set -terrain.size * 0.5, 0, -terrain.size * 0.5

    spacing = 0.5
    geometry = new THREE.BoxGeometry 1-spacing, 1, 1-spacing

    @columns = []
    for x in [0...@size]
      @columns[x] = []
      for y in [0...@size]
        height = terrain.heightAt x / @size, y / @size
        continue unless 0 <= height < 100

        column = new THREE.Mesh geometry,
          new THREE.MeshPhongMaterial 0xffffff

        column.position.set 0, 0.5, 0

        origin = new THREE.Object3D()
        origin.add column
        origin.position.set x + 0.5, 0, y + 0.5
        origin.scale.set 1, -0.01, 1

        @columns[x][y] = origin
        root.add origin

    # Data functions
    @functions = []

    @functions.push new Function
      name: "Median Rent"
      data: new DataMap 'medianrent.png'

    @functions.push new Function
      name: "Median Income"
      data: new DataMap 'medianincome.png'

    @functions.push new Function
      name: "Mortgage Affordability"
      data: new DataMap 'homeaffordability.png'

    @functions.push new Function
      name: "Population Density"
      data: new DataMap 'density.png'

    @functions.push new Function
      name: "Household Density"
      data: new DataMap 'density2.png'

    @functions.push new Function
      name: "Public Transport"
      data: new DataMap 'publictransport.png'

    @functions.push new Function
      name: "School API Score"
      data: new DataMap 'schools.png'

    @functions.push new Function
      name: "Regulated Air Sites"
      data: new DataMap 'regulatedairsites.png'

    @functions.push new Function
      name: "Toxic Release Inventory"
      data: new DataMap 'toxicreleaseinventory.png'

    @functions.push new Function
      name: "Greenhouse Gas Inventory"
      data: new DataMap 'greenhousegasinventory.png'

    @functions.push new Function
      name: "Asian"
      data: new DataMap 'asian.png'

    @functions.push new Function
      name: "Black"
      data: new DataMap 'black.png'

    @functions.push new Function
      name: "Hispanic"
      data: new DataMap 'hispanic.png'

    @functions.push new Function
      name: "White"
      data: new DataMap 'white.png'

    # Gradients
    @gradient = new Gradient 'gradient.png'

  valueAt: (x, y, dataMap) ->
    dataMap.valueAt x / @size, y / @size

  update: ->
    for x in [0...@size]
      for y in [0...@size]
        column = @columns[x][y]
        continue unless column

        targetValue = 1
        totalWeights = 0

        for dataFunction in @functions
          value = @valueAt x, y, dataFunction
          weight = dataFunction.weight()
          totalWeights += weight

          base = 1 - weight
          range = weight
          targetValue *= base + range * value

        targetValue = 0.001 unless totalWeights

        currentValue = column.scale.y
        delta = targetValue - currentValue
        newValue = currentValue + delta * 0.1
        newValue = Math.max newValue, 0.001

        column.scale.y = newValue

        column.children[0].material.color.set @gradient.colorAt newValue
