import * as CANNON from 'https://cdn.skypack.dev/cannon-es';
import * as THREE from "three";
import * as BufferGeometryUtils from "three/addons/utils/BufferGeometryUtils.js";
// import * as $ from "nui://game/ui/jquery.js";

const canvasEl = document.querySelector('#dice-canvas');
const scoreResult = document.querySelector('#dice-score-result');
const scoreResultOponent = document.querySelector('#dice-score-result-oponent');
const rollBtn = document.querySelector('#dice-roll-btn');

let renderer, scene, camera, diceMesh, physicsWorld;

const params = {
    numberOfDice: 2,
    segments: 40,
    edgeRadius: .1,
    notchRadius: .15,
    notchDepth: .09,
};

const texture = new THREE.TextureLoader().load( "https://i.imgur.com/1IWEP7s.png" );
texture.repeat.set( 1, 1 );

const diceArray = [];

initPhysics();
initScene();

window.addEventListener('resize', updateSceneSize);

function initScene() {

    renderer = new THREE.WebGLRenderer({
        alpha: true,
        antialias: true,
        canvas: canvasEl
    });
    renderer.shadowMap.enabled = true
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));

    scene = new THREE.Scene();
    camera = new THREE.PerspectiveCamera(45, window.innerWidth / window.innerHeight, .1, 100)
    camera.position.set(0, 5.4, 2.5).multiplyScalar(6);
    camera.lookAt(0.0, 0.0, 4.5);
	 camera.updateProjectionMatrix();
    updateSceneSize();

    const ambientLight = new THREE.AmbientLight(0xffffff, .3);
    scene.add(ambientLight);
    const topLight = new THREE.PointLight(0xffffff, .5);
    topLight.position.set(10, 15, 3);
    topLight.castShadow = true;
    topLight.shadow.mapSize.width = 2048;
    topLight.shadow.mapSize.height = 2048;
    topLight.shadow.camera.near = 5;
    topLight.shadow.camera.far = 400;
    scene.add(topLight);

    createFloor();
    diceMesh = createDiceMesh();
    for (let i = 0; i < params.numberOfDice; i++) {
        diceArray.push(createDice());
        addDiceEvents(diceArray[i],true);
    }

    // throwDice();

    render();
}

function initPhysics() {
    physicsWorld = new CANNON.World({
        allowSleep: true,
        gravity: new CANNON.Vec3(0, -60, 0),
    })
    physicsWorld.defaultContactMaterial.restitution = .3;
}


function createFloor() {
	const material = new THREE.MeshBasicMaterial( { map: texture } 	);
    const floor = new THREE.Mesh(
        new THREE.PlaneGeometry(35, 35),
        material
    )
    floor.receiveShadow = true;
    floor.position.y = -7;
    floor.quaternion.setFromAxisAngle(new THREE.Vector3(-1, 0, 0), Math.PI * .5);
    scene.add(floor);

    const floorBody = new CANNON.Body({
        type: CANNON.Body.STATIC,
        shape: new CANNON.Plane(),
    });
    floorBody.position.copy(floor.position);
    floorBody.quaternion.copy(floor.quaternion);
    physicsWorld.addBody(floorBody);
}

function createDiceMesh() {
    const boxMaterialOuter = new THREE.MeshStandardMaterial({
        color: 0xeeeeee,
    })
    const boxMaterialInner = new THREE.MeshStandardMaterial({
        color: 0x000000,
        roughness: 0,
        metalness: 1,
        side: THREE.DoubleSide
    })

    const diceMesh = new THREE.Group();
    const innerMesh = new THREE.Mesh(createInnerGeometry(), boxMaterialInner);
    const outerMesh = new THREE.Mesh(createBoxGeometry(), boxMaterialOuter);
    outerMesh.castShadow = true;
    diceMesh.add(innerMesh, outerMesh);

    return diceMesh;
}

function createDice() {
    const mesh = diceMesh.clone();
    scene.add(mesh);

    const body = new CANNON.Body({
        mass: .3,
        shape: new CANNON.Box(new CANNON.Vec3(.5, .5, .5)),
        sleepTimeLimit: .02
    });
    physicsWorld.addBody(body);

    return {mesh, body};
}

function createBoxGeometry() {

    let boxGeometry = new THREE.BoxGeometry(1, 1, 1, params.segments, params.segments, params.segments);

    const positionAttr = boxGeometry.attributes.position;
    const subCubeHalfSize = .5 - params.edgeRadius;

    for (let i = 0; i < positionAttr.count; i++) {

        let position = new THREE.Vector3().fromBufferAttribute(positionAttr, i);

        const subCube = new THREE.Vector3(Math.sign(position.x), Math.sign(position.y), Math.sign(position.z)).multiplyScalar(subCubeHalfSize);
        const addition = new THREE.Vector3().subVectors(position, subCube);

        if (Math.abs(position.x) > subCubeHalfSize && Math.abs(position.y) > subCubeHalfSize && Math.abs(position.z) > subCubeHalfSize) {
            addition.normalize().multiplyScalar(params.edgeRadius);
            position = subCube.add(addition);
        } else if (Math.abs(position.x) > subCubeHalfSize && Math.abs(position.y) > subCubeHalfSize) {
            addition.z = 0;
            addition.normalize().multiplyScalar(params.edgeRadius);
            position.x = subCube.x + addition.x;
            position.y = subCube.y + addition.y;
        } else if (Math.abs(position.x) > subCubeHalfSize && Math.abs(position.z) > subCubeHalfSize) {
            addition.y = 0;
            addition.normalize().multiplyScalar(params.edgeRadius);
            position.x = subCube.x + addition.x;
            position.z = subCube.z + addition.z;
        } else if (Math.abs(position.y) > subCubeHalfSize && Math.abs(position.z) > subCubeHalfSize) {
            addition.x = 0;
            addition.normalize().multiplyScalar(params.edgeRadius);
            position.y = subCube.y + addition.y;
            position.z = subCube.z + addition.z;
        }

        const notchWave = (v) => {
            v = (1 / params.notchRadius) * v;
            v = Math.PI * Math.max(-1, Math.min(1, v));
            return params.notchDepth * (Math.cos(v) + 1.);
        }
        const notch = (pos) => notchWave(pos[0]) * notchWave(pos[1]);

        const offset = .23;

        if (position.y === .5) {
            position.y -= notch([position.x, position.z]);
        } else if (position.x === .5) {
            position.x -= notch([position.y + offset, position.z + offset]);
            position.x -= notch([position.y - offset, position.z - offset]);
        } else if (position.z === .5) {
            position.z -= notch([position.x - offset, position.y + offset]);
            position.z -= notch([position.x, position.y]);
            position.z -= notch([position.x + offset, position.y - offset]);
        } else if (position.z === -.5) {
            position.z += notch([position.x + offset, position.y + offset]);
            position.z += notch([position.x + offset, position.y - offset]);
            position.z += notch([position.x - offset, position.y + offset]);
            position.z += notch([position.x - offset, position.y - offset]);
        } else if (position.x === -.5) {
            position.x += notch([position.y + offset, position.z + offset]);
            position.x += notch([position.y + offset, position.z - offset]);
            position.x += notch([position.y, position.z]);
            position.x += notch([position.y - offset, position.z + offset]);
            position.x += notch([position.y - offset, position.z - offset]);
        } else if (position.y === -.5) {
            position.y += notch([position.x + offset, position.z + offset]);
            position.y += notch([position.x + offset, position.z]);
            position.y += notch([position.x + offset, position.z - offset]);
            position.y += notch([position.x - offset, position.z + offset]);
            position.y += notch([position.x - offset, position.z]);
            position.y += notch([position.x - offset, position.z - offset]);
        }

        positionAttr.setXYZ(i, position.x, position.y, position.z);
    }


    boxGeometry.deleteAttribute('normal');
    boxGeometry.deleteAttribute('uv');
    boxGeometry = BufferGeometryUtils.mergeVertices(boxGeometry);

    boxGeometry.computeVertexNormals();

    return boxGeometry;
}

function createInnerGeometry() {
    const baseGeometry = new THREE.PlaneGeometry(1 - 2 * params.edgeRadius, 1 - 2 * params.edgeRadius);
    const offset = .48;
    return BufferGeometryUtils.mergeBufferGeometries([
        baseGeometry.clone().translate(0, 0, offset),
        baseGeometry.clone().translate(0, 0, -offset),
        baseGeometry.clone().rotateX(.5 * Math.PI).translate(0, -offset, 0),
        baseGeometry.clone().rotateX(.5 * Math.PI).translate(0, offset, 0),
        baseGeometry.clone().rotateY(.5 * Math.PI).translate(-offset, 0, 0),
        baseGeometry.clone().rotateY(.5 * Math.PI).translate(offset, 0, 0),
    ], false);
}

function addDiceEvents(dice) {
    let times = 0;
    dice.body.addEventListener('sleep', (e) => {

        dice.body.allowSleep = false;

        const euler = new CANNON.Vec3();
        e.target.quaternion.toEuler(euler);

        const eps = .1;
        let isZero = (angle) => Math.abs(angle) < eps;
        let isHalfPi = (angle) => Math.abs(angle - .5 * Math.PI) < eps;
        let isMinusHalfPi = (angle) => Math.abs(.5 * Math.PI + angle) < eps;
        let isPiOrMinusPi = (angle) => (Math.abs(Math.PI - angle) < eps || Math.abs(Math.PI + angle) < eps);


        if (times > 0){
            if (isZero(euler.z)) {
                if (isZero(euler.x)) {
                    showRollResults(1);
                } else if (isHalfPi(euler.x)) {
                    showRollResults(4);
                } else if (isMinusHalfPi(euler.x)) {
                    showRollResults(3);
                } else if (isPiOrMinusPi(euler.x)) {
                    showRollResults(6);
                } else {
                    // landed on edge => wait to fall on side and fire the event again
                    dice.body.allowSleep = true;
                }
            } else if (isHalfPi(euler.z)) {
                showRollResults(2);
            } else if (isMinusHalfPi(euler.z)) {
                showRollResults(5);
            } else {
                // landed on edge => wait to fall on side and fire the event again
                dice.body.allowSleep = true;
            }
        }
        times++;
    });
}

let oponent_turn = false;
let results = [];
function showRollResults(score) {
    if (((oponent_turn && scoreResultOponent) || scoreResult).innerHTML === '') {
        ((oponent_turn && scoreResultOponent) || scoreResult).innerHTML += '' + score;
        results.push(score);
    } else {
        ((oponent_turn && scoreResultOponent) || scoreResult).innerHTML += (' + ' + score);
        results.push(score);
    }
    if (results.length >= 2){
        post("dices:results",{results: results});
        results = [];
    }
}

function render() {
    physicsWorld.fixedStep();

    for (const dice of diceArray) {
        dice.mesh.position.copy(dice.body.position)
        dice.mesh.quaternion.copy(dice.body.quaternion)
    }

    renderer.render(scene, camera);
    requestAnimationFrame(render);
}

function updateSceneSize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
}

let throwLock = false;

function throwDice(randomFactor,forceFactor) {
    ((oponent_turn && scoreResultOponent) || scoreResult).innerHTML = '';

    diceArray.forEach((d, dIdx) => {

        d.body.velocity.setZero();
        d.body.angularVelocity.setZero();

        d.body.position = new CANNON.Vec3(4, dIdx * 1.5, -.5);
        d.mesh.position.copy(d.body.position);

        d.mesh.rotation.set(2 * Math.PI * randomFactor, 0, 2 * Math.PI * randomFactor)
        d.body.quaternion.copy(d.mesh.quaternion);

        const force = 1 + 2 * forceFactor;
        d.body.applyImpulse(
            new CANNON.Vec3(-force, force, 0),
            new CANNON.Vec3(0, 0, .2)
        );

        d.body.allowSleep = true;
    });
}


let dicesActive = false;
function diceStart(data){
    dicesActive  = true;
    $(".dice_container").fadeIn();
    document.getElementById("ply_name").innerHTML = data.ply;
    document.getElementById("opo_name").innerHTML = data.opo;
}
function diceStop(data){
    dicesActive = false;
    $(".dice_container").fadeOut();
    post("dices:escape");
}

rollBtn.addEventListener('click', function(){
    post("dices:tryRoll");
});

// setTimeout(() => {
//     diceStart();
// }, 2000);

window.addEventListener("message",function(evt){
  var data = evt.data;

  switch(data.act){
    case "diceGame":
      switch(data.event){
          case "start":
            oponent_turn = false;
              diceStart(data.data);
          break
          case "close":
              diceStop(data.data);
          break
          case "exit":
            dicesActive = false;
            $(".dice_container").fadeOut();
          case "roll":
            if (data.data.turn == 2){
              oponent_turn = true;
            } else {
                oponent_turn = false;
            }
            throwDice(data.data.randomFactor,data.data.forceFactor);
          break
      }
    break
  }
});

window.addEventListener('keyup', function(e){
  switch(e.code){
    case 'Escape':
      if (dicesActive){
        diceStop();
      }
    break
  }
});