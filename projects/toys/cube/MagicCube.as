//
// $Id$

package {

import flash.display.Bitmap;
import flash.display.Sprite;

import flash.events.Event;

import com.threerings.util.Assert;

import com.threerings.flash.FrameSprite;

import org.papervision3d.Papervision3D;
import org.papervision3d.cameras.Camera3D;
import org.papervision3d.core.proto.MaterialObject3D;
import org.papervision3d.materials.BitmapMaterial;
import org.papervision3d.materials.ColorMaterial;
import org.papervision3d.materials.special.CompositeMaterial;
import org.papervision3d.objects.DisplayObject3D;
import org.papervision3d.objects.primitives.Cube;
import org.papervision3d.objects.primitives.Plane;
import org.papervision3d.view.BasicView;

/**
 * A 3D Magic Cube (Rubik's Cube) toy.
 */
[SWF(width="400", height="400")]
public class MagicCube extends FrameSprite
{
    public function MagicCube ()
    {
        _view = new BasicView(400, 400, false);
        addChild(_view);

        _root = new DisplayObject3D("rootNode");
        _view.scene.addChild(_root);

        var material :MaterialObject3D;

        const FACE :MaterialObject3D = new BitmapMaterial(Bitmap(new FACE_TEXTURE()).bitmapData);

        // set up our materials
        var m :Array = [ 0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00, 0xFF00FF, 0x00FFFF ];
        m = m.map(function (color :uint, ... ignored) :Object {
            var comp :CompositeMaterial = new CompositeMaterial();
            comp.addMaterial(new ColorMaterial(color));
            comp.addMaterial(FACE);
            return comp;
        });

        // a material to use for minicube faces that are sometimes exposed during a rotation
        // TODO
        const CORE :MaterialObject3D = new ColorMaterial(0x000000);

        // create the top face of minicubes
        addCube([ m[0], null, null, m[1], m[2], null ], { x: -1, y: 1, z: 1 });
        addCube([ m[0], null, null, null, m[2], null ], { x: 0, y: 1, z: 1 });
        addCube([ m[0], null, null, null, m[2], m[3] ], { x: 1, y: 1, z: 1 });

        addCube([ m[0], null, null, m[1], null, null ], { x: -1, y: 1, z: 0 });
        addCube([ m[0], null, null, null, null, null ], { x: 0, y: 1, z: 0 });
        addCube([ m[0], null, null, null, null, m[3] ], { x: 1, y: 1, z: 0 });

        addCube([ m[0], null, m[4], m[1], null, null ], { x: -1, y: 1, z: -1 });
        addCube([ m[0], null, m[4], null, null, null ], { x: 0, y: 1, z: -1 });
        addCube([ m[0], null, m[4], null, null, m[3] ], { x: 1, y: 1, z: -1 });

        // create the middle ring of minicubes (no corners)
        addCube([ null, null, null, m[1], m[2], null ], { x: -1, y: 0, z: 1 });
        addCube([ null, null, null, null, m[2], null ], { x: 0, y: 0, z: 1 });
        addCube([ null, null, null, null, m[2], m[3] ], { x: 1, y: 0, z: 1 });

        addCube([ null, null, null, m[1], null, null ], { x: -1, y: 0, z: 0 });
        // omit the very center cube: no visible faces
        addCube([ null, null, null, null, null, m[3] ], { x: 1, y: 0, z: 0 });

        addCube([ null, null, m[4], m[1], null, null ], { x: -1, y: 0, z: -1 });
        addCube([ null, null, m[4], null, null, null ], { x: 0, y: 0, z: -1 });
        addCube([ null, null, m[4], null, null, m[3] ], { x: 1, y: 0, z: -1 });

        // now the bottom row
        addCube([ null, m[5], null, m[1], m[2], null ], { x: -1, y: -1, z: 1 });
        addCube([ null, m[5], null, null, m[2], null ], { x: 0, y: -1, z: 1 });
        addCube([ null, m[5], null, null, m[2], m[3] ], { x: 1, y: -1, z: 1 });

        addCube([ null, m[5], null, m[1], null, null ], { x: -1, y: -1, z: 0 });
        addCube([ null, m[5], null, null, null, null ], { x: 0, y: -1, z: 0 });
        addCube([ null, m[5], null, null, null, m[3] ], { x: 1, y: -1, z: 0 });

        addCube([ null, m[5], m[4], m[1], null, null ], { x: -1, y: -1, z: -1 });
        addCube([ null, m[5], m[4], null, null, null ], { x: 0, y: -1, z: -1 });
        addCube([ null, m[5], m[4], null, null, m[3] ], { x: 1, y: -1, z: -1 });

        _root.rotationX = 180;

        _view.cameraAsCamera3D.lookAt(_root);
        _view.cameraAsCamera3D.zoom = 30000;
        _view.cameraAsCamera3D.focus = 1;
        //_camera = new Camera3D(_root, 30000, 1);
    }

    protected function addCube (materials :Array, initObject :Object) :void
    {
        var cube :DisplayObject3D = makeUnitCube(materials, initObject);
        _root.addChild(cube);

        // TODO: more
    }

    /**
     * @param materials an Array of materials or null to omit the face.
     *        face order: [ top, bottom, front, left, back, right ]
     */
    protected function makeUnitCube (materials :Array, initObject :Object = null) :DisplayObject3D
    {
        var minicube :DisplayObject3D = new DisplayObject3D(null, null, initObject);

        for (var ii :int = 0; ii < 6; ii++) {
            var mat :MaterialObject3D = materials[ii] as MaterialObject3D;
            if (mat == null) {
                continue;
            }
            var face :Plane = new Plane(mat, 1, 1);
            switch (ii) {
            case 0: // top
                face.pitch(90);
                face.y = .5;
                break;

            case 1: // bottom
                face.pitch(-90);
                face.y = -.5;
                break;

            case 2: // front
                face.z = -.5;
                break;

            case 3: // left
                face.yaw(90);
                face.x = -.5;
                break;

            case 4: // back
                face.pitch(180);
                face.z = .5;
                break;

            case 5: // right
                face.yaw(-90);
                face.x = .5;
                break;
            }
            minicube.addChild(face);
        }

        return minicube;
    }

    override protected function handleFrame (... ignored) :void
    {
        _root.rotationX += Math.random();
        _root.rotationY += Math.random();
        _root.rotationZ += Math.random() * 2;
        _view.singleRender();
    }

    protected var _root :DisplayObject3D;

    protected var _view :BasicView;

    [Embed(source="face.png")]
    protected static const FACE_TEXTURE :Class;
}
}
