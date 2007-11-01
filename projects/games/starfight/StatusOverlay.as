package {

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.Bitmap;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFieldAutoSize;

import com.threerings.util.HashMap;

public class StatusOverlay extends Sprite
{
    public static const SHIP :int = 0;
    public static const POWERUP :int = 1;

    public static const RADAR_RAD :int = 50;
    public static const RADAR_ZOOM :int = 25;

    public function StatusOverlay () :void
    {
        addChild(_power = new Sprite());
        _power.graphics.beginFill(Codes.CYAN);
        _power.graphics.drawRoundRect(0, 0, POW_WIDTH, POW_HEIGHT, 2.0, 2.0);
        _power.x = StarFight.WIDTH - 103;
        _power.y = 38;
        var mask :Shape = new Shape();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, 0, POW_WIDTH, POW_HEIGHT);
        _power.addChild(mask);
        _power.mask = mask;

        addChild(Bitmap(new radarAsset()));
        addChild(_radar = new Sprite());
        _radar.x = 70;
        _radar.y = 61;
        var vitals :Bitmap = Bitmap(new vitalsAsset());
        addChild(vitals);
        vitals.x = StarFight.WIDTH - 109;

        addChild(_spread = (Bitmap(new spreadAsset())));
        _spread.x = StarFight.WIDTH - 104;
        _spread.y = 63;
        addChild(_speed = (Bitmap(new speedAsset())));
        _speed.x = StarFight.WIDTH - 73;
        _speed.y = 63;
        addChild(_shields = (Bitmap(new shieldsAsset())));
        _shields.x = StarFight.WIDTH - 42;
        _shields.y = 63;

        var format:TextFormat = new TextFormat();
        format.font = "Verdana";
        format.color = Codes.CYAN;
        format.size = 16;
        format.bold = true;

        _score = 0;
        _scoreText = new TextField();
        _scoreText.autoSize = TextFieldAutoSize.RIGHT;
        _scoreText.selectable = false;
        //_scoreText.textColor = Codes.CYAN;
        // center the label above us
        _scoreText.x = StarFight.WIDTH - 25;
        _scoreText.y = 5;
        _scoreText.defaultTextFormat = format;
        _scoreText.text = String(_score);
        addChild(_scoreText);

/*
        _hiScore = 0;
        _hiScoreText = new TextField();
        _hiScoreText.autoSize = TextFieldAutoSize.LEFT;
        _hiScoreText.selectable = false;
        _hiScoreText.x = 20;
        _hiScoreText.y = 8;
        _hiScoreText.defaultTextFormat = format;
        addChild(_hiScoreText);

        _hiNameText = new TextField();
        _hiNameText.autoSize = TextFieldAutoSize.LEFT;
        _hiNameText.selectable = false;
        _hiNameText.x = 20;
        _hiNameText.y = 28;
        format.size = 10;
        _hiNameText.defaultTextFormat = format;
        addChild(_hiNameText);
*/
    }

    /**
     * Shows the powerups held by the ship.
     */
    public function setPowerups (powerups :int) :void
    {
        _speed.alpha = ((powerups & ShipSprite.SPEED_MASK) ? 1.0 : 0.0);
        _spread.alpha = ((powerups & ShipSprite.SPREAD_MASK) ? 1.0 : 0.0);
        _shields.alpha = ((powerups & ShipSprite.SHIELDS_MASK) ? 1.0 : 0.0);
    }

    /**
     * Sets our power level.
     */
    public function setPower (power :Number) :void
    {
        var mask :Shape = Shape(_power.mask);
        mask.graphics.clear();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, 0, POW_WIDTH*power, POW_HEIGHT);
        mask.graphics.endFill();
    }

    /**
     * Add some points to our score.
     */
    public function addScore (score :Number) :void
    {
        _score += score;
        _scoreText.text = String(_score);
    }

    /**
     * Sets the hi score readout.
     */
    public function checkHiScore (ship :ShipSprite) :void
    {
    /*
        if (ship.score > _hiScore) {
            _hiScoreText.text = String(ship.score);
            _hiNameText.text = ship.playerName;
            _hiScore = ship.score;
        }
        */
    }

    /**
     * Adds a ship to the radar.
     */
    public function addShip (id :int) :void
    {
        var dot :Shape = createDot(SHIP);
        _ships.put(id, dot);
        _radar.addChild(dot);
    }

    /**
     * Rmoves a ship from the radar.
     */
    public function removeShip (id :int) :void
    {
        _radar.removeChild(_ships.remove(id));
    }

    /**
     * Adds a powerup to the radar.
     */
    public function addPowerup (id :int) :void
    {
        var dot :Shape = createDot(POWERUP);
        _powerups.put(id, dot);
        _radar.addChild(dot);
    }

    /**
     * Rmoves a powerup from the radar.
     */
    public function removePowerup (id :int) :void
    {
        _radar.removeChild(_powerups.remove(id));
    }

    /**
     * Updates the radar display.
     */
    public function updateRadar (ships :HashMap, powerups :Array, board :Sprite) :void
    {
        ships.forEach(function (key :Object, value :Object) :void {
            var dot :Shape = _ships.get(int(key));
            if (dot != null) {
                var sprite :Sprite = Sprite(value);
                positionDot(dot, sprite.x, sprite.y);
            }
        });
        for (var ii :int = 0; ii < powerups.length; ii++) {
            if (powerups[ii] != null) {
                var dot :Shape = _powerups.get(ii);
                if (dot != null) {
                    positionDot(dot, powerups[ii].x + board.x, powerups[ii].y + board.y);
                }
            }
        }
    }

    /**
     * Positions the dot inside the radar.
     */
    protected function positionDot (dot :Shape, x :Number, y :Number) :void
    {
        x = (x - StarFight.WIDTH/2) / RADAR_ZOOM;
        y = (y - StarFight.HEIGHT/2) / RADAR_ZOOM;

        if (x*x + y*y < RADAR_RAD*RADAR_RAD) {
            dot.x = x;
            dot.y = y;
            return;
        }
        var angle :Number = Math.atan2(y, x);
        dot.x = Math.cos(angle) * RADAR_RAD;
        dot.y = Math.sin(angle) * RADAR_RAD;
    }

    /**
     * Creates a new dot for use on the radar.
     */
    protected function createDot (type :int) :Shape
    {
        var color :uint;
        if (type == SHIP) {
            color = 0xFF0000;
        } else {
            color = 0x00FF00;
        }
        var circle :Shape = new Shape();
        circle.graphics.beginFill(color);
        circle.graphics.lineStyle(1, color);
        circle.graphics.drawCircle(0, 0, 2);
        circle.graphics.endFill();
        return circle;
    }

    [Embed(source="rsrc/status_vitals.png")]
    protected var vitalsAsset :Class;

    [Embed(source="rsrc/status_radar.png")]
    protected var radarAsset :Class;

    [Embed(source="rsrc/spread.png")]
    protected var spreadAsset :Class;

    [Embed(source="rsrc/speed.png")]
    protected var speedAsset :Class;

    [Embed(source="rsrc/shields.png")]
    protected var shieldsAsset :Class;

    /** Powerup bitmaps. */
    protected var _speed :Bitmap;
    protected var _spread :Bitmap;
    protected var _shields :Bitmap;

    /** HP bar. */
    protected var _power :Sprite;
    protected var _radar :Sprite;

    /** Score readout. */
    protected var _score :int;
    protected var _hiScore :int;
    protected var _scoreText :TextField;
    protected var _hiScoreText :TextField;
    protected var _hiNameText :TextField;

    /** Radar elements. */
    protected var _ships :HashMap = new HashMap();
    protected var _powerups :HashMap = new HashMap();

    protected static const POW_WIDTH :int = 85;
    protected static const POW_HEIGHT :int = 8;
}
}
