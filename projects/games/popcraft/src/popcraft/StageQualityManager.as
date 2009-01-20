package popcraft {

import flash.display.StageQuality;

public class StageQualityManager
{
    public static function get stageQuality () :String
    {
        if (ClientContext.gameCtrl.isConnected()) {
            if (null == _stageQuality) {
                _stageQuality = StageQuality.MEDIUM;
            }

            return _stageQuality;
        } else {
            return ClientContext.mainSprite.stage.quality;
        }
    }

    public static function set stageQuality (quality :String) :void
    {
        if (ClientContext.gameCtrl.isConnected()) {
            ClientContext.gameCtrl.local.setStageQuality(quality);
            _stageQuality = quality;
        } else {
            ClientContext.mainSprite.stage.quality = quality;
        }
    }

    public static function pushStageQuality (quality :String) :void
    {
        _stageQualityStack.push(StageQualityManager.stageQuality);
        StageQualityManager.stageQuality = quality;
    }

    public static function popStageQuality () :void
    {
        if (_stageQualityStack.length > 0) {
            var lastQuality :String = _stageQualityStack.pop();
            StageQualityManager.stageQuality = lastQuality;
        }
    }

    protected static var _stageQuality :String;
    protected static var _stageQualityStack :Array = [];
}

}
