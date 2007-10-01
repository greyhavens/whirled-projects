// $Id$

package {

import flash.display.Sprite;
import flash.display.BlendMode;

import flash.geom.Matrix;

public class Board extends Sprite
{
    public function Board () 
    {
        var colorBackground :Sprite = new Sprite();
        colorBackground.graphics.beginFill(BACKGROUND_COLOR);
        colorBackground.graphics.drawRect(-Locksmith.DISPLAY_WIDTH / 2 , 
            -Locksmith.DISPLAY_HEIGHT / 2, Locksmith.DISPLAY_WIDTH, Locksmith.DISPLAY_HEIGHT);
        addChild(colorBackground);

        addLaunchers();
        addGoals();

        _loadedLauncher = -1;
    }

    public function addRing (ring :Ring) :void
    {
        addChild(_ring = ring);
    }

    public function loadNextLauncher () :void
    {
        var launcherAngles :Array = [ { blue: 45, red: 135 }, { blue: 0, red: 180 },
            { blue: 315, red: 225 } ];
        var launcherHoles :Array = [ { blue: 2, red: 6 }, { blue: 0, red: 8 },
            { blue: 14, red: 10 } ];
        _loadedLauncher = (_loadedLauncher + 1) % 3;
        var trans :Matrix = new Matrix();
        trans.translate(Ring.SIZE_PER_RING * 5.5, 0);
        trans.rotate(-launcherAngles[_loadedLauncher].blue * Math.PI / 180);
        var blueLaunchMarble :Marble = new Marble(this, _ring.largest, 
            launcherHoles[_loadedLauncher].blue, Marble.BLUE);
        blueLaunchMarble.transform.matrix = trans;
        addChild(blueLaunchMarble);
        trans = new Matrix();
        trans.translate(Ring.SIZE_PER_RING * 5.5, 0);
        trans.rotate(-launcherAngles[_loadedLauncher].red * Math.PI / 180);
        var redLaunchMarble :Marble = new Marble(this, _ring.largest, 
            launcherHoles[_loadedLauncher].red, Marble.RED);
        redLaunchMarble.transform.matrix = trans;
        addChild(redLaunchMarble);
        DoLater.instance.registerAt(DoLater.ROTATION_END, function (currentStage :int) :void {
            blueLaunchMarble.launch();
            redLaunchMarble.launch();
        });
    }

    public function set scoreBoard (scoreBoard :ScoreBoard) :void 
    {
        _scoreBoard = scoreBoard;
    }

    public function scorePoint (color :int) :void
    {
        if (_scoreBoard != null) {
            if (color == Marble.RED) {
                _scoreBoard.redScore++;
            } else {
                _scoreBoard.blueScore++;
            }   
        }
    }

    public function stopRotation () :void
    {
        var ring :Ring = _ring.smallest;
        while (ring != null) {
            ring.stopRotation();
            ring = ring.outer;
        }
    }

    protected function addLaunchers () :void
    {
        // give the marbles a little breating room
        var size :int = Marble.SIZE + 4;
        var launchersSprite :Sprite = new Sprite();
        var launchers :Array = [ 
            { angle: 0, color: LAUNCH_BLUE }, { angle: 45, color: LAUNCH_BLUE },
            { angle: 135, color: LAUNCH_RED }, { angle: 180, color: LAUNCH_RED },
            { angle: 225, color: LAUNCH_RED }, { angle: 315, color: LAUNCH_BLUE }];
        for (var ii :int = 0; ii < launchers.length; ii++) {
            var launcher :Sprite = new Sprite();
            launcher.graphics.beginFill(launchers[ii].color);
            launcher.graphics.drawRect(-size / 2, -size / 2, size, size);
            launcher.graphics.endFill();
            var trans :Matrix = new Matrix();
            trans.translate(Ring.SIZE_PER_RING * 5.5, 0);
            trans.rotate(-launchers[ii].angle * Math.PI / 180);
            launcher.transform.matrix = trans;
            launchersSprite.addChild(launcher);
        }
        addChild(launchersSprite);
    }

    protected function addGoals () :void
    {
        // red goal
        var goals :Sprite = new Sprite();
        goals.blendMode = BlendMode.LAYER;
        var goal :Sprite = new Sprite();
        var color :Sprite = new Sprite();
        color.graphics.beginFill(LAUNCH_RED);
        color.graphics.drawCircle(0, 0, Ring.SIZE_PER_RING);
        color.graphics.endFill();
        goal.addChild(color);
        var mask :Sprite = new Sprite();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(-Ring.SIZE_PER_RING, -Ring.SIZE_PER_RING, Ring.SIZE_PER_RING, 
            Ring.SIZE_PER_RING * 2);
        mask.graphics.endFill();
        mask.blendMode = BlendMode.ERASE;
        goal.addChild(mask);
        goals.addChild(goal);

        // blue goal
        goal = new Sprite();
        goal.blendMode = BlendMode.LAYER;
        color = new Sprite();
        color.graphics.beginFill(LAUNCH_BLUE);
        color.graphics.drawCircle(0, 0, Ring.SIZE_PER_RING);
        color.graphics.endFill();
        goal.addChild(color);
        mask = new Sprite();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(0, -Ring.SIZE_PER_RING, Ring.SIZE_PER_RING, 
            Ring.SIZE_PER_RING * 2);
        mask.graphics.endFill();
        mask.blendMode = BlendMode.ERASE;
        goal.addChild(mask);
        goals.addChild(goal);

        // neutral zone
        var zone :Sprite = new Sprite();
        zone.blendMode = BlendMode.LAYER;
        color = new Sprite();
        color.graphics.beginFill(0);
        color.graphics.drawCircle(0, 0, Ring.SIZE_PER_RING);
        color.graphics.endFill();
        zone.addChild(color);
        mask = new Sprite();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(Ring.SIZE_PER_RING / 2, -Ring.SIZE_PER_RING, Ring.SIZE_PER_RING / 2,
            Ring.SIZE_PER_RING * 2);
        mask.graphics.endFill();
        mask.blendMode = BlendMode.ERASE;
        zone.addChild(mask);
        mask = new Sprite();
        mask.graphics.beginFill(0);
        mask.graphics.drawRect(-Ring.SIZE_PER_RING, -Ring.SIZE_PER_RING, Ring.SIZE_PER_RING / 2, 
            Ring.SIZE_PER_RING * 2);
        mask.blendMode = BlendMode.ERASE;
        zone.addChild(mask);
        goals.addChild(zone);

        addChild(goals);
    }

    protected static const LAUNCH_BLUE :int = 0x6D7BFC;
    protected static const LAUNCH_RED :int = 0xFE8585;

    protected static const BACKGROUND_COLOR :int = 0x5C4A38;

    protected var _loadedLauncher :int;
    protected var _ring :Ring;
    protected var _scoreBoard :ScoreBoard;
}
}
