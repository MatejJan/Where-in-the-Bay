class window.Terrain
  constructor: (@size, onMeshCreated) ->
    terrainMaterial = new THREE.MeshLambertMaterial
      color: 0x909090
      map: new THREE.TextureLoader().load "terrain.jpg"

    crustMaterial = new THREE.MeshLambertMaterial
      color: 0x909090
      map: new THREE.TextureLoader().load "crust.png"

    material = new THREE.MultiMaterial()

    material.materials = [
      terrainMaterial
      crustMaterial
    ]

    @height = @size * 0.03
    @depth = @size * 0.1
    @resolution = 800

    texture = new THREE.TextureLoader().load "heightmap.png", =>
      image = texture.image
      size = image.width
      canvas = document.createElement 'canvas'
      canvas.width = size
      canvas.height = size
      canvas.getContext('2d').drawImage image, 0, 0, size, size
      imageData = canvas.getContext('2d').getImageData(0, 0, size, size).data

      geometry = new THREE.Geometry()

      heightFunction = (x, y) =>
        heightX = Math.floor(x * size / @resolution)
        heightY = Math.floor(y * size / @resolution)
        heightIndex = heightY * size + heightX
        height = imageData[heightIndex * 4] - 12
        height = -1 if height < 0
        height

      @heightAt = (x, y) =>
        heightFunction(x * @resolution, y * @resolution)

      # Create vertices.
      console.log "Creating vertices."
      for x in [0...@resolution]
        for y in [0...@resolution]
          height = heightFunction(x, y)
          geometry.vertices.push new THREE.Vector3 x / (@resolution-1) * @size, height / 255 * @height, y / (@resolution-1) * @size

      # Create edge vertices.
      edgeIndicesOffset = geometry.vertices.length
      for i in [0...@resolution]
        for j in [0..3]
          x = i
          y = i

          switch j
            when 0 then y = 0
            when 1 then y = @resolution-1
            when 2 then x = 0
            when 3 then x = @resolution-1

          height = heightFunction(x, y)
          geometry.vertices.push new THREE.Vector3 x / (@resolution-1) * @size, height / 255 * @height, y / (@resolution-1) * @size
          geometry.vertices.push new THREE.Vector3 x / (@resolution-1) * @size, -@depth, y / (@resolution-1) * @size

      # Create faces.
      console.log "Creating faces."
      for x in [0...@resolution-1]
        for y in [0...@resolution-1]
          # Calculate vertex indices [t]op/[b]ottom/[l]eft/[r]ight.
          tl = y * @resolution + x
          tr = tl + 1
          bl = (y + 1) * @resolution + x
          br = bl + 1
          geometry.faces.push new THREE.Face3 tl, br, bl
          geometry.faces.push new THREE.Face3 tl, tr, br

          uvs =
            tl: new THREE.Vector2 (y / (@resolution-1)), 1-(x / (@resolution-1))
            tr: new THREE.Vector2 (y / (@resolution-1)), 1-((x+1) / (@resolution-1))
            bl: new THREE.Vector2 ((y+1) / (@resolution-1)), 1-(x / (@resolution-1))
            br: new THREE.Vector2 ((y+1) / (@resolution-1)), 1-((x+1) / (@resolution-1))

          geometry.faceVertexUvs[0].push [uvs.tl, uvs.br, uvs.bl]
          geometry.faceVertexUvs[0].push [uvs.tl, uvs.tr, uvs.br]

      # Create edge faces.
      for i in [0...@resolution-1]
        for j in [0..3]
          tl = edgeIndicesOffset + i * 8 + j * 2
          bl = tl + 1
          tr = tl + 8
          br = tr + 1

          uvs =
            tl: new THREE.Vector2 i / (@resolution-1), 1
            tr: new THREE.Vector2 (i+1) / (@resolution-1), 1
            bl: new THREE.Vector2 i / (@resolution-1), 0
            br: new THREE.Vector2 (i+1) / (@resolution-1), 0

          if j is 0 or j is 3
            geometry.faces.push new THREE.Face3 tl, tr, bl, null, null, 1
            geometry.faces.push new THREE.Face3 bl, tr, br, null, null, 1
            geometry.faceVertexUvs[0].push [uvs.tl, uvs.tr, uvs.bl]
            geometry.faceVertexUvs[0].push [uvs.bl, uvs.tr, uvs.br]

          else
            geometry.faces.push new THREE.Face3 tl, bl, tr, null, null, 1
            geometry.faces.push new THREE.Face3 bl, br, tr, null, null, 1
            geometry.faceVertexUvs[0].push [uvs.tl, uvs.bl, uvs.tr]
            geometry.faceVertexUvs[0].push [uvs.bl, uvs.br, uvs.tr]



      console.log "Computing attributes."
      geometry.computeFaceNormals()
      geometry.computeVertexNormals()
      geometry.computeBoundingBox()
      geometry.computeBoundingSphere()

      console.log "Terrain created."
      @mesh = new THREE.Mesh geometry, material
      onMeshCreated @mesh
