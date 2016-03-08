# Setup the renderer.

renderer = new THREE.WebGLRenderer
  antialias: true

renderer.setClearColor 0x424254
renderer.setPixelRatio devicePixelRatio

document.body.appendChild renderer.domElement

# Setup the camera.
terrainSize = 10000

camera = new THREE.PerspectiveCamera 50, window.innerWidth / window.innerHeight, terrainSize * 0.01, terrainSize * 10

camera.position.set terrainSize, terrainSize * 0.7, terrainSize
camera.lookAt new THREE.Vector3 0, 0, 0

# Setup the scene.
scene = new THREE.Scene()

scene.add new THREE.AmbientLight 0x424254 * 2

sun = new THREE.DirectionalLight 0xffffff, 1.5
sun.position.set(-2, 2, 0.5)
scene.add sun

ocean = new Ocean renderer, camera, sun, scene, terrainSize

dataGrid = null
terrain = new Terrain terrainSize, (mesh) ->
  mesh.position.set -terrain.size * 0.5, 0, -terrain.size * 0.5
  scene.children[0].add mesh

  # Data grid
  dataGrid = new DataGrid scene.children[0], terrain

# Input
controls = new THREE.OrbitControls camera, renderer.domElement
controls.enableDamping = true
controls.dampingFactor = 0.25
controls.enableKeys = false
controls.maxPolarAngle = Math.PI / 2.1

# Window resizing

onWindowResize = ->
  camera.aspect = window.innerWidth / window.innerHeight
  camera.setViewOffset window.innerWidth * 1.15, window.innerHeight * 1.05, 0, window.innerHeight * 0.05, window.innerWidth, window.innerHeight
  camera.updateProjectionMatrix()
  renderer.setSize window.innerWidth, window.innerHeight

onWindowResize()
window.addEventListener 'resize', onWindowResize, false

# Draw loop

draw = ->
  requestAnimationFrame draw

  dataGrid?.update()

  scene.updateMatrixWorld()
  renderer.clear()
  ocean.draw() if ocean
  renderer.render scene, camera

draw()

# Export to global namespace.
window.renderer = renderer
window.camera = camera
window.scene = scene
