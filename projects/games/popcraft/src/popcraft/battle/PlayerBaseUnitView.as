package popcraft.battle {
    
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;

import popcraft.*;
import popcraft.util.*;

public class PlayerBaseUnitView extends SceneObject
{
    public function PlayerBaseUnitView (unit :PlayerBaseUnit)
    {
        _unit = unit;
        
        var playerColor :uint = Constants.PLAYER_COLORS[_unit.owningPlayerId];
        
        // add the image, aligned by its foot position
        var image :Bitmap = (PopCraft.resourceManager.getResource(_unit.unitData.name) as ImageResourceLoader).createBitmap();
        image.x = -(image.width * 0.5);
        image.y = -image.height;
        _sprite.addChild(image);

        // add a glow around the image
        _sprite.addChild(ImageUtil.createGlowBitmap(image, playerColor));
        
        // health meter
        _healthMeter = new RectMeter();
        _healthMeter.minValue = 0;
        _healthMeter.maxValue = _unit.unitData.maxHealth;
        _healthMeter.value = _unit.health;
        _healthMeter.foregroundColor = playerColor;
        _healthMeter.backgroundColor = 0x888888;
        _healthMeter.outlineColor = 0x000000;
        _healthMeter.width = 30;
        _healthMeter.height = 3;
        _healthMeter.x = -(_healthMeter.width * 0.5);
        _healthMeter.y = -_sprite.height - _healthMeter.height;
    }
    
    override protected function addedToDB () :void
    {
        this.db.addObject(_healthMeter, _sprite);
    }
    
    override protected function destroyed () :void
    {
        _healthMeter.destroySelf();
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    override protected function update (dt :Number) :void
    {
        this.x = _unit.x;
        this.y = _unit.y;
        
        var health :Number = _unit.health;
        
        _healthMeter.value = health;
        
        if (health <= 0) {
            this.destroySelf();
        }
    }
    
    protected var _sprite: Sprite = new Sprite();
    protected var _unit :PlayerBaseUnit;
    protected var _healthMeter :RectMeter;
    
}

}