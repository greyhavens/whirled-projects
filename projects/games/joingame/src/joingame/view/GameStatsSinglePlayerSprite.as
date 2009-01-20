package joingame.view
{
    import com.threerings.util.StringBuilder;
    import com.whirled.contrib.simplegame.resource.ResourceManager;
    import com.whirled.contrib.simplegame.resource.SwfResource;
    
    import de.flamelab.util.Sprintf;
    
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.text.AntiAliasType;
    import flash.text.StyleSheet;
    import flash.text.TextField;
    import flash.text.TextFormat;
    
    import joingame.Constants;
    import joingame.UserCookieDataSourcePlayer;
    public class GameStatsSinglePlayerSprite extends Sprite
    {
        
//        [Embed(source="..//fonts/MeliorLTStd.otf", fontName='emMelior', mimeType='application/x-font')]
//        public static var MeliorFont:Class;


        protected var _textField :TextField;

        protected var _buttons :Sprite;
        protected var _leftButtonEdge :int;
        protected var _rightButtonEdge :int;
    
        protected var _styleSheet :StyleSheet;
    
        protected static const GAP :int = 8;
        
        public var _panel :MovieClip;
    
    
        public function GameStatsSinglePlayerSprite(oldCookie :UserCookieDataSourcePlayer, newCookie :UserCookieDataSourcePlayer)
        {
            
//            var swfRoot :MovieClip = MovieClip(SwfResource.getSwfDisplayRoot("UI"));
//            _modeLayer.addChild(swfRoot);
//            
//            _out_placer = MovieClip(swfRoot["out_placer"]);
//            _marquee_placer = MovieClip(swfRoot["marquee_placer"]);
            
            var swf :SwfResource = (ResourceManager.instance.getResource("UI") as SwfResource);
            var panelClass :Class = swf.getClass("panel");
            _panel = new panelClass();
            _panel.scaleX = 2.5;
            _panel.scaleY = 2.5;
            _panel.x = Constants.SCREEN_SIZE.x/2;
            _panel.y = Constants.SCREEN_SIZE.y/2 + 50;
            
            addChild( _panel );
            
            
            _styleSheet = new StyleSheet();
            _styleSheet.parseCSS(
            "body {" +
            "  color: #000000;" +
            "}" +
            ".title {" +
            "  font-family: CooperBlackStd;" +
            "  font-size: 20;" +
            "  text-decoration: underline;" +
            "  text-align: left;" +
            "  margin-left: 20;" +
            "}" +
            ".shim {" +
            "  font-size: 8;" +
            "}" +
            ".summary {" +
            "  font-family: Goudy;" +
            "  font-weight: bold;" +
            "  font-size: 16;" +
            "  text-align: left;" +
            "}" +
            ".message {" +
            "  font-family: Goudy;" +
            "  font-size: 16;" +
            "  text-align: left;" +
            "}" +
            ".details {" +
            "  font-family: Goudy;" +
            "  font-size: 14;" +
            "  text-align: left;" +
            "}");

        _textField = new TextField();
        _panel.addChild(_textField);
        _textField.x = -65;
        _textField.y = -40;
//        _textField.defaultTextFormat = getDefaultFormat();
//        _textField.styleSheet = _styleSheet;
        _textField.selectable = false;
        _textField.textColor = 0x000000;
//        _textField.wordWrap = true;
        _textField.multiline = true;
        _textField.embedFonts = true;
        _textField.antiAliasType = AntiAliasType.ADVANCED;
//        _textField.autoSize = TextFieldAutoSize.CENTER;
        _textField.width = 800;
        _textField.height = 800;
        _textField.scaleX = 0.2;
        _textField.scaleY = _textField.scaleX;
//        _textField.htmlText = em(txt);
        _textField.text = createTextFromCookies( oldCookie, newCookie );
//        _buttons = new Sprite();
//        this.addChild(_buttons);

        var tf:TextFormat = new TextFormat();
        tf.color = 0x000000;
        tf.size = 30;
        tf.font = "CooperBlackStd";
        _textField.setTextFormat(tf);
//        _buttons.x = GAP;
//        _buttons.y = GAP;
//
//        _textField.x = GAP;
//        _textField.y = GAP;
//
//        _rightButtonEdge = _textField.width;
//        _leftButtonEdge = 0;
//        
            
            
            
            
            
            
            
            
            
//            graphics.beginFill(0xffffff);
//            graphics.drawRect(0, 0, 200, 100)
//            graphics.endFill();
//            
//            addChild( createText("Level: " + newCookie.highestRobotLevelDefeated + ", old level: " + oldCookie.highestRobotLevelDefeated, 0, 10));
//            x = 200;
            
            //Somewhere else
            
        }
        
        protected function createTextFromCookies( oldCookie :UserCookieDataSourcePlayer, newCookie :UserCookieDataSourcePlayer) :String 
        {
            var sb :StringBuilder = new StringBuilder();
            var format :Function = Sprintf.format; 
            sb.append( format("%60s",  "Change:\n"));
            var addition :String = "";
            if( newCookie.highestRobotLevelDefeated > oldCookie.highestRobotLevelDefeated) {
                addition = "+" + (newCookie.highestRobotLevelDefeated - oldCookie.highestRobotLevelDefeated);    
            }
            else {
                addition= "-";
            }
            sb.append( format("Level:%30s%20s", newCookie.highestRobotLevelDefeated, addition));
            
            sb.append("\n");
            newCookie.bestKillsPerDeltaRatio = 0.123456789;
            var maxStringSize :int = 5;
            var ratingString :String = "" + oldCookie.bestKillsPerDeltaRatio;
            sb.append( format("Best Rating:                   %1.3f%s", oldCookie.bestKillsPerDeltaRatio, "\n"));
//            ratingString = "" + newCookie.bestKillsPerDeltaRatio;
            addition = "";
//            sb.append( "Current Rating:\t\t" + ratingString.substr(0, maxStringSize) );
//            if( newCookie.bestKillsPerDeltaRatio > oldCookie.bestKillsPerDeltaRatio) {
//                ratingString = "" + (newCookie.bestKillsPerDeltaRatio - oldCookie.bestKillsPerDeltaRatio);
                 
                if( newCookie.bestKillsPerDeltaRatio > oldCookie.bestKillsPerDeltaRatio) {
//                    ratingString = "+" + ratingString;
                    addition = "+";
                }
                sb.append( format("Current Rating:            %1.3f      "+addition+"%1.3f%s", newCookie.bestKillsPerDeltaRatio,(newCookie.bestKillsPerDeltaRatio - oldCookie.bestKillsPerDeltaRatio), "\n"));
//                sb.append( format(" ",);    
//            }
//            else {
//                sb.append( "\t\t  -");
//            }
//            sb.append("\n   (Boards destroyed per move)\n");
            sb.append("\n");
            
            
            return sb.toString();
        }
        
        protected static function em (text :String) :String
        {
            return text.replace(/\[\[/g, "<b><i>").replace(/\]\]/g, "</i></b>");
        }
        
    }
}