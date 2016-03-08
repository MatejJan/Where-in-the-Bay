class window.Ocean
  constructor: (renderer, camera, light, scene, size) ->
    waterNormals = new THREE.TextureLoader().load('waternormals.jpg')
    waterNormals.wrapS = waterNormals.wrapT = THREE.RepeatWrapping

    @water = new THREE.Water renderer, camera, scene,
      textureWidth: 1024
      textureHeight: 1024
      waterNormals: waterNormals
      alpha: 0.5
      sunDirection: light.position.clone().normalize()
      sunColor: 0xffffff
      waterColor: 0x070411
      distortionScale: size * 0.01

    mirrorMesh = new THREE.Mesh new THREE.PlaneBufferGeometry(size, size), @water.material
    mirrorMesh.add @water
    mirrorMesh.rotation.x = -Math.PI * 0.5
    scene.add mirrorMesh

  draw: ->
    @water.material.uniforms.time.value += 1.0 / 60.0
    @water.render()
