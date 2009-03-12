package vampire.avatar {

import com.threerings.util.HashMap;
import com.whirled.AvatarControl;
import com.whirled.ControlEvent;
import com.whirled.DataPack;
import com.whirled.contrib.ColorMatrix;

import flash.display.MovieClip;
import flash.filters.BitmapFilter;
import flash.filters.ColorMatrixFilter;
import flash.utils.ByteArray;

public class VampireBody extends NewBody
{
    public function VampireBody (ctrl :AvatarControl, media :MovieClip, width :int,
                                 height :int = -1)
    {
        super(ctrl, media, width, height);

        _skintones = new HashMap();
        _skintones.put("lighter", 0xDEEFF5);
        _skintones.put("light", 0xD0DFFD);
        _skintones.put("cool", 0xC2EDD3);
        _skintones.put("warm", 0xE1C2ED);
        _skintones.put("dark", 0xC7B4EB);
        _skintones.put("darker", 0xCCCCCC);

        // Remix-based configuration
        //DataPack.load(_ctrl.getDefaultDataPack(), onDataPackLoaded);

        // Entity memory-based configuration
        loadConfig();
        if (_ctrl.hasControl()) {
            showConfigPanel();
        }
        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED,
            function (e :ControlEvent) :void {
                if (e.name == MEMORY_CONFIG) {
                    loadConfig();
                }
            });
    }

    protected function showConfigPanel () :void
    {
        var panel :ConfigPanel = new ConfigPanel(
            _curConfig,
            function (previewConfig :VampatarConfig) :void {
                applyConfig(previewConfig);
            },
            function (newConfig :VampatarConfig) :void {
                if (newConfig != null) {
                    _curConfig = newConfig;
                    saveConfig(newConfig);
                    applyConfig(newConfig);
                } else {
                    applyConfig(_curConfig);
                }
                _ctrl.clearPopup();
            });

        _ctrl.showPopup("Configure!", panel, panel.width, panel.height);
    }

    protected function loadConfig () :void
    {
        var config :VampatarConfig = new VampatarConfig();
        var bytes :ByteArray = _ctrl.getMemory(MEMORY_CONFIG) as ByteArray;
        if (bytes != null) {
            try {
                bytes.position = 0;
                config.fromBytes(bytes);
            } catch (e :Error) {
                log.warning("Error loading VampatarConfig", e);
            }
        }

        _curConfig = config;
        applyConfig(_curConfig);
    }

    protected function saveConfig (config :VampatarConfig) :void
    {
        _ctrl.setMemory(MEMORY_CONFIG, config.toBytes(),
            function (success :Boolean) :void {
                if (!success) {
                    log.warning("Failed to save VampatarConfig!");
                }
            });
    }

    protected function onDataPackLoaded (result :Object) :void
    {
        var config :VampatarConfig = new VampatarConfig();

        if (!(result is DataPack)) {
            log.warning("Unexpected DataPack data", "result", result);

        } else {
            var pack :DataPack = result as DataPack;

            var skinSelection :String = pack.getString("SkinColorChooser");
            if (_skintones.containsKey(skinSelection)) {
                config.skinColor = _skintones.get(skinSelection);
            } else {
                config.skinColor = pack.getColor("SkinColor");
            }

            config.hairColor = pack.getColor("HairColor");
            config.shirtColor = pack.getColor("ShirtColor");
            config.pantsColor = pack.getColor("PantsColor");
            config.shoesColor = pack.getColor("ShoesColor");
            config.shirtNumber = pack.getInt("Shirt");
            config.hairNumber = pack.getInt("Hair");
            config.shoesNumber = pack.getInt("Shoes");
        }

        applyConfig(config);
    }

    protected function applyConfig (config :VampatarConfig) :void
    {
        var skinFilter :ColorMatrixFilter = createColorFilter(config.skinColor);
        var hairFilter :ColorMatrixFilter = createColorFilter(config.hairColor);
        var shirtFilter :ColorMatrixFilter = createColorFilter(config.shirtColor);
        var pantsFilter :ColorMatrixFilter = createColorFilter(config.pantsColor);
        var shoesFilter :ColorMatrixFilter = createColorFilter(config.shoesColor);

        for each (var movie :MovieClip in getAllMovies()) {
            // Shirt
            selectFrame(movie, [ "torso", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "neck", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "hips", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "breasts", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "breasts", "breasts" ], config.shirtNumber);
            selectFrame(movie, [ "bicepL", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "bicepR", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "bicepL", "bicepL" ], config.shirtNumber);
            selectFrame(movie, [ "bicepR", "bicepR" ], config.shirtNumber);
            selectFrame(movie, [ "forearmL", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "forearmR", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "forearmL", "forearmL" ], config.shirtNumber);
            selectFrame(movie, [ "forearmR", "forearmR" ], config.shirtNumber);
            selectFrame(movie, [ "handL", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "handR", "shirt" ], config.shirtNumber);
            selectFrame(movie, [ "handL", "handL" ], config.shirtNumber);
            selectFrame(movie, [ "handR", "handR" ], config.shirtNumber);

            // Hair
            selectFrame(movie, [ "head", "scalp", "scalp" ], config.hairNumber);
            selectFrame(movie, [ "bangs", "bangs" ], config.hairNumber);
            selectFrame(movie, [ "hairL", "hairL" ], config.hairNumber);
            selectFrame(movie, [ "hairR", "hairR" ], config.hairNumber);
            selectFrame(movie, [ "hair", "hair" ], config.hairNumber);
            selectFrame(movie, [ "hairTips", "hairTips" ], config.hairNumber);

            // Shoes
            selectFrame(movie, [ "footL", "shoes" ], config.shoesNumber);
            selectFrame(movie, [ "footR", "shoes" ], config.shoesNumber);
            selectFrame(movie, [ "footL", "foot" ], config.shoesNumber);
            selectFrame(movie, [ "footR", "foot" ], config.shoesNumber);
            selectFrame(movie, [ "calfL", "shoes" ], config.shoesNumber);
            selectFrame(movie, [ "calfR", "shoes" ], config.shoesNumber);

            // Skin color
            applyFilter(movie, [ "head", "head" ], skinFilter);
            applyFilter(movie, [ "head", "ear" ], skinFilter);
            applyFilter(movie, [ "neck", "neck" ], skinFilter);
            applyFilter(movie, [ "bicepL", "bicepL" ], skinFilter);
            applyFilter(movie, [ "bicepR", "bicepR" ], skinFilter);
            applyFilter(movie, [ "forearmL", "forearmL" ], skinFilter);
            applyFilter(movie, [ "forearmR", "forearmR" ], skinFilter);
            applyFilter(movie, [ "handL", "handL" ], skinFilter);
            applyFilter(movie, [ "handR", "handR" ], skinFilter);
            applyFilter(movie, [ "breasts", "breasts" ], skinFilter);
            applyFilter(movie, [ "torso", "torso" ], skinFilter);
            applyFilter(movie, [ "hips", "hips" ], skinFilter);
            applyFilter(movie, [ "calfL", "calfL" ], skinFilter);
            applyFilter(movie, [ "calfR", "calfR" ], skinFilter);
            applyFilter(movie, [ "footL", "foot" ], skinFilter);
            applyFilter(movie, [ "footR", "foot" ], skinFilter);

            // Hair color
            applyFilter(movie, [ "head", "scalp", "scalp", ], hairFilter);
            applyFilter(movie, [ "head", "eyebrows", ], hairFilter);
            applyFilter(movie, [ "hairTips", "hairTips", ], hairFilter);
            applyFilter(movie, [ "bangs", "bangs", ], hairFilter);
            applyFilter(movie, [ "hairL", "hairL", ], hairFilter);
            applyFilter(movie, [ "hairR", "hairR", ], hairFilter);
            applyFilter(movie, [ "hair", "hair", ], hairFilter);

            // Shirt color
            applyFilter(movie, [ "neck", "shirt", ], shirtFilter);
            applyFilter(movie, [ "bicepL", "shirt", ], shirtFilter);
            applyFilter(movie, [ "bicepR", "shirt", ], shirtFilter);
            applyFilter(movie, [ "forearmL", "shirt", ], shirtFilter);
            applyFilter(movie, [ "forearmR", "shirt", ], shirtFilter);
            applyFilter(movie, [ "handL", "shirt", ], shirtFilter);
            applyFilter(movie, [ "handR", "shirt", ], shirtFilter);
            applyFilter(movie, [ "breasts", "shirt", ], shirtFilter);
            applyFilter(movie, [ "torso", "shirt", ], shirtFilter);
            applyFilter(movie, [ "hips", "shirt", ], shirtFilter);

            // Pants color
            applyFilter(movie, [ "hips", "pants", ], pantsFilter);
            applyFilter(movie, [ "thighL", "pants", ], pantsFilter);
            applyFilter(movie, [ "thighR", "pants", ], pantsFilter);
            applyFilter(movie, [ "calfL", "pants", ], pantsFilter);
            applyFilter(movie, [ "calfR", "pants", ], pantsFilter);
            applyFilter(movie, [ "footL", "pants", ], pantsFilter);
            applyFilter(movie, [ "footR", "pants", ], pantsFilter);

            // Shoes color
            applyFilter(movie, [ "calfL", "shoes", ], shoesFilter);
            applyFilter(movie, [ "calfR", "shoes", ], shoesFilter);
            applyFilter(movie, [ "footL", "shoes", ], shoesFilter);
            applyFilter(movie, [ "footR", "shoes", ], shoesFilter);
        }
    }

    protected static function findChild (movie :MovieClip, childPath :Array) :MovieClip
    {
        var child :MovieClip = movie;
        for each (var pathElt :String in childPath) {
            child = child[pathElt];
            if (child == null) {
                break;
            }
        }

        return child;
    }

    protected static function selectFrame (movie :MovieClip, childPath :Array,
                                           frameNumber :int) :void
    {
        var child :MovieClip = findChild(movie, childPath);
        if (child != null) {
            child.gotoAndStop(frameNumber);
        }
    }

    protected static function applyFilter (movie :MovieClip, childPath :Array,
                                           filter :BitmapFilter) :void
    {
        var child :MovieClip = findChild(movie, childPath);
        if (child != null) {
            child.filters = [ filter ];
        }
    }

    protected static function createColorFilter (color :uint) :ColorMatrixFilter
    {
        return new ColorMatrix().colorize(color).createFilter();
    }

    protected var _skintones :HashMap;
    protected var _curConfig :VampatarConfig;

    protected static const MEMORY_CONFIG :String = "VampatarConfig";
}

}

import com.whirled.AvatarControl;
import flash.utils.ByteArray;
import flash.display.Sprite;
import flash.display.Graphics;
import flash.display.SimpleButton;
import com.threerings.flash.SimpleTextButton;
import flash.events.MouseEvent;
import com.threerings.util.Random;

class VampatarConfig
{
    public var skinColor :uint = 0xD0DFFD;
    public var hairColor :uint = 0x220000;
    public var shirtColor :uint = 0x222222;
    public var pantsColor :uint = 0x203030;
    public var shoesColor :uint = 0x000008;
    public var shirtNumber :int = 1;
    public var hairNumber :int = 2;
    public var shoesNumber :int = 3;

    public function clone () :VampatarConfig
    {
        var theClone :VampatarConfig = new VampatarConfig();
        var bytes :ByteArray = toBytes();
        bytes.position = 0;
        theClone.fromBytes(bytes);
        return theClone;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeByte(VERSION);

        ba.writeUnsignedInt(skinColor);
        ba.writeUnsignedInt(hairColor);
        ba.writeUnsignedInt(shirtColor);
        ba.writeUnsignedInt(pantsColor);
        ba.writeUnsignedInt(shoesColor);
        ba.writeByte(shirtNumber);
        ba.writeByte(hairNumber);
        ba.writeByte(shoesNumber);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        var version :int = ba.readByte();
        if (version > VERSION) {
            throw new Error("Version too high. Expected " + VERSION + ", got " + version);
        }

        skinColor = ba.readUnsignedInt();
        hairColor = ba.readUnsignedInt();
        shirtColor = ba.readUnsignedInt();
        pantsColor = ba.readUnsignedInt();
        shoesColor = ba.readUnsignedInt();
        shirtNumber = ba.readByte();
        hairNumber = ba.readByte();
        shoesNumber = ba.readByte();
    }

    protected static const VERSION :int = 0;
}

class ConfigPanel extends Sprite
{
    public function ConfigPanel (config :VampatarConfig,
                                 showConfigCallback :Function,
                                 closePanelCallback :Function) :void
    {
        _originalConfig = config;
        _config = config.clone();
        _showConfigCallback = showConfigCallback;
        _closePanelCallback = closePanelCallback;

        var skintones :Array = [ 0xDEEFF5, 0xD0DFFD, 0xC2EDD3, 0xE1C2ED, 0xC7B4EB, 0xCCCCCC ];
        var randomize :SimpleButton = new SimpleTextButton("Randomize");
        randomize.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _config.skinColor = randPick(skintones);
                _config.hairColor = rand(0xff000000, 0xffffffff);
                _config.shirtColor = rand(0xff000000, 0xffffffff);
                _config.pantsColor = rand(0xff000000, 0xffffffff);
                _config.shoesColor = rand(0xff000000, 0xffffffff);
                _config.shirtNumber = rand(1, 3);
                _config.hairNumber = rand(1, 4);
                _config.shoesNumber = rand(1, 3);
                configUpdated();
            });
        randomize.y = this.height;
        addChild(randomize);

        var reset :SimpleButton = new SimpleTextButton("Reset");
        reset.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _config = _originalConfig.clone();
                configUpdated();
            });
        reset.y = this.height + 5;
        addChild(reset);

        var cancel :SimpleButton = new SimpleTextButton("Cancel");
        cancel.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _closePanelCallback(null);
            });
        cancel.y = this.height + 10;
        addChild(cancel);

        var ok :SimpleButton = new SimpleTextButton("OK");
        ok.addEventListener(MouseEvent.CLICK,
            function (...ignored) :void {
                _closePanelCallback(_config);
            });
        ok.y = this.height + 5;
        addChild(ok);
    }

    protected function configUpdated () :void
    {
        _showConfigCallback(_config);
    }

    protected function randPick (arr :Array) :*
    {
        return (arr.length == 0 ? undefined : arr[rand(0, arr.length - 1)]);
    }

    protected function rand (lo :uint, hi :uint) :uint
    {
        return lo + (Math.random() * (hi - lo + 1));
    }

    protected var _originalConfig :VampatarConfig;
    protected var _config :VampatarConfig;
    protected var _showConfigCallback :Function;
    protected var _closePanelCallback :Function;
}
