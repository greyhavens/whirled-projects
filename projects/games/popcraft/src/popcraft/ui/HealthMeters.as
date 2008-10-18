package popcraft.ui {

import flash.geom.Point;

public class HealthMeters
{
    public static function createWorkshopMeters (playerColor :uint, maxHealth :Number, health :Number)
        :Array
    {
        var meters :Array = [];
        while (maxHealth > 0) {
            var thisMaxHealth :Number = Math.min(maxHealth, WORKSHOP_METER_MAX_MAX_VALUE);
            var thisHealth :Number = Math.min(health, thisMaxHealth);
            meters.push(HealthMeters.createWorkshopMeter(playerColor, thisMaxHealth, thisHealth));
            maxHealth -= thisMaxHealth;
            health -= thisHealth;
        }

        return meters;
    }

    public static function createWorkshopMeter (playerColor :uint, maxHealth :Number, health :Number)
        :RectMeterView
    {
        var width :Number = WORKSHOP_METER_SIZE.x * (maxHealth / WORKSHOP_METER_MAX_MAX_VALUE);

        var healthMeter :RectMeterView = new RectMeterView();
        healthMeter.minValue = 0;
        healthMeter.maxValue = maxHealth;
        healthMeter.value = health;
        healthMeter.foregroundColor = playerColor;
        healthMeter.backgroundColor = BG_COLOR;
        healthMeter.outlineColor = OUTLINE_COLOR;
        healthMeter.meterWidth = width;
        healthMeter.meterHeight = WORKSHOP_METER_SIZE.y;
        healthMeter.updateDisplay();

        return healthMeter;
    }

    public static function createCreatureMeter (playerColor :uint, maxHealth :Number, health :Number)
        :RectMeterView
    {
        var healthMeter :RectMeterView = new RectMeterView();
        healthMeter.minValue = 0;
        healthMeter.maxValue = maxHealth;
        healthMeter.value = health;
        healthMeter.foregroundColor = playerColor;
        healthMeter.backgroundColor = BG_COLOR;
        healthMeter.outlineColor = OUTLINE_COLOR;
        healthMeter.meterWidth = CREATURE_METER_SIZE.x;
        healthMeter.meterHeight = CREATURE_METER_SIZE.y;
        healthMeter.updateDisplay();

        return healthMeter;
    }

    protected static const WORKSHOP_METER_MAX_MAX_VALUE :Number = 150;
    protected static const WORKSHOP_METER_SIZE :Point = new Point(50, 6);
    protected static const CREATURE_METER_SIZE :Point = new Point(30, 3);
    protected static const BG_COLOR :uint = 0x888888;
    protected static const OUTLINE_COLOR :uint = 0x000000;
}

}
