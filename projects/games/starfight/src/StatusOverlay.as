package {

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.Bitmap;

import flash.text.AntiAliasType;
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
        addChild(Resources.getBitmap("status_radar.png"));
        addChild(_radar = new Sprite());
        _radar.x = 70;
        _radar.y = 61;
        var vitals :Bitmap = Resources.getBitmap("status_vitals.png");
        addChild(vitals);
        vitals.x = StarFight.WIDTH - 109;

        addChild(_health = new Sprite());
        _health.x = StarFight.WIDTH - 103;
        _health.y = 8;
        _health.addChild(Resources.getBitmap("bar_health.png"));
        var mask :Shape = new Shape();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, 0, HEALTH_WIDTH, HEALTH_HEIGHT);
        _health.addChild(mask);
        _health.mask = mask;
        addChild(_primary = new Sprite());
        _primary.x = StarFight.WIDTH - 91;
        _primary.y = 39;
        _primary.addChild(Resources.getBitmap("bar_shot.png"));
        mask = new Shape();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, 0, POW_WIDTH, POW_HEIGHT);
        _primary.addChild(mask);
        _primary.mask = mask;
        addChild(_secondary = new Sprite());
        _secondary.x = StarFight.WIDTH - 91;
        _secondary.y = 56;
        _secondary.addChild(Resources.getBitmap("bar_secondary.png"));
        mask = new Shape();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, 0, POW_WIDTH, POW_HEIGHT);
        _secondary.addChild(mask);
        _secondary.mask = mask;

        addChild(_spread = new Sprite());
        _spread.x = StarFight.WIDTH - 103;
        _spread.y = 84;
        _spread.addChild(Resources.getBitmap("spread.png"));
        mask = new Shape();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, 0, POW_SIZE, POW_SIZE);
        _spread.addChild(mask);
        _spread.mask = mask;
        addChild(_speed = new Sprite());
        _speed.addChild(Resources.getBitmap("speed.png"));
        _speed.x = StarFight.WIDTH - 71;
        _speed.y = 84;
        mask = new Shape();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, 0, POW_SIZE, POW_SIZE);
        _speed.addChild(mask);
        _speed.mask = mask;
        addChild(_shields = new Sprite());
        _shields.addChild(Resources.getBitmap("shields.png"));
        _shields.x = StarFight.WIDTH - 39;
        _shields.y = 84;
        mask = new Shape();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, 0, POW_SIZE, POW_SIZE);
        _shields.addChild(mask);
        _shields.mask = mask;

        var format:TextFormat = new TextFormat();
        format.font = StarFight.gameFont.fontName;
        format.color = Codes.CYAN;
        format.size = 16;
        format.bold = true;

        _roundText = new TextField();
        _roundText.autoSize = TextFieldAutoSize.CENTER;
        _roundText.selectable = false;
        _roundText.embedFonts = true;
        _roundText.antiAliasType = AntiAliasType.ADVANCED;
        _roundText.defaultTextFormat = format;
        addChild(_roundText);
    }

    /**
     * Shows the powerups held by the ship.
     */
    public function setPowerups (ship :ShipSprite) :void
    {
        var mask :Shape = Shape(_speed.mask);
        mask.graphics.clear();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, POW_SIZE * (1.0 - ship.enginePower), POW_SIZE, POW_SIZE);
        mask.graphics.endFill();

        mask = Shape(_spread.mask);
        mask.graphics.clear();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, POW_SIZE * (1.0 - ship.weaponPower), POW_SIZE, POW_SIZE);
        mask.graphics.endFill();

        mask = Shape(_shields.mask);
        mask.graphics.clear();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(
            0, POW_SIZE * (1.0 - Math.min(1.0, ship.shieldPower)), POW_SIZE, POW_SIZE);
        mask.graphics.endFill();

        mask = Shape(_primary.mask);
        mask.graphics.clear();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, 0, POW_WIDTH * ship.primaryPower, POW_HEIGHT);
        mask.graphics.endFill();

        mask = Shape(_secondary.mask);
        mask.graphics.clear();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, 0, POW_WIDTH * ship.secondaryPower, POW_HEIGHT);
        mask.graphics.endFill();
    }

    /**
     * Sets our power level.
     */
    public function setPower (power :Number) :void
    {
        var mask :Shape = Shape(_health.mask);
        mask.graphics.clear();
        mask.graphics.beginFill(0xFFFFFF);
        mask.graphics.drawRect(0, 0, HEALTH_WIDTH*power, HEALTH_HEIGHT);
        mask.graphics.endFill();
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
    public function updateRadar (
            ships :HashMap, powerups :Array, boardX :Number, boardY :Number) :void
    {
        boardX = StarFight.WIDTH/2 - boardX*Codes.PIXELS_PER_TILE;
        boardY = StarFight.HEIGHT/2 - boardY*Codes.PIXELS_PER_TILE;
        ships.forEach(function (key :Object, value :Object) :void {
            var dot :Shape = _ships.get(int(key));
            if (dot != null) {
                var sprite :ShipSprite = ShipSprite(value);
                dot.visible = sprite.isAlive();
                positionDot(dot, sprite.x, sprite.y);
            }
        });
        for (var ii :int = 0; ii < powerups.length; ii++) {
            if (powerups[ii] != null) {
                var dot :Shape = _powerups.get(ii);
                if (dot != null) {
                    positionDot(dot, powerups[ii].x + boardX, powerups[ii].y + boardY);
                }
            }
        }
    }

    /**
     * Updates the round text display.
     */
     public function updateRoundText (text :String) :void
     {
        _roundText.text = text;
        _roundText.x = (StarFight.WIDTH - _roundText.width) / 2;
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
            color = Codes.RED;
        } else {
            color = Codes.GREEN;
        }
        var circle :Shape = new Shape();
        circle.graphics.beginFill(color);
        circle.graphics.lineStyle(1, color);
        circle.graphics.drawCircle(0, 0, 2);
        circle.graphics.endFill();
        return circle;
    }

    /** Powerup bitmaps. */
    protected var _speed :Sprite;
    protected var _spread :Sprite;
    protected var _shields :Sprite;

    /** HP bar. */
    protected var _health :Sprite;
    protected var _primary :Sprite;
    protected var _secondary :Sprite;
    protected var _radar :Sprite;

    /** Score readout. */
    protected var _score :int;
    protected var _hiScore :int;
    protected var _scoreText :TextField;

    /** Radar elements. */
    protected var _ships :HashMap = new HashMap();
    protected var _powerups :HashMap = new HashMap();

    /** Status elements. */
    protected var _roundText :TextField;

    protected static const POW_WIDTH :int = 72;
    protected static const POW_HEIGHT :int = 6;
    protected static const HEALTH_WIDTH :int = 86;
    protected static const HEALTH_HEIGHT :int = 15;
    protected static const POW_SIZE :int = 25;
}
}