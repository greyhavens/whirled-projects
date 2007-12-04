//
// $Id$

package dictattack {

import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

/**
 * Displays game help.
 */
public class HelpView extends Dialog
{
    public static function show (ctx :Context) :void
    {
        if (_showing == null) {
            _showing = new HelpView(ctx);
            _showing.show();
        }
    }

    public function HelpView (ctx :Context)
    {
        super(ctx);

        var help :TextField = new TextField();
        help.defaultTextFormat = _ctx.content.makeInputFormat(uint(0xFFFFFF));
        help.autoSize = TextFieldAutoSize.LEFT;
        help.wordWrap = true;
        help.width = HELP_WIDTH;
        help.htmlText = (makeHelp(HELP_CONTENTS) +
                         makeHelp(ctx.model.isMultiPlayer() ? HELP_MULTI : HELP_SINGLE));
        setContent(help);

        var dismiss :SimpleButton = _ctx.content.makeButton("Dismiss");
        dismiss.addEventListener(MouseEvent.CLICK, function (event :MouseEvent) :void {
            clear();
            _showing = null;
        });
        addButton(dismiss, Dialog.CENTER);
    }

    protected function makeHelp (text :String) :String
    {
        return text.replace(
            "MINLEN", _ctx.model.getMinWordLength()).replace(
                "POINTS", _ctx.model.getWinningPoints()).replace(
                    "ROUNDS", _ctx.model.getWinningScore());
    }

    protected static var _showing :HelpView;

    protected static const HELP_WIDTH :int = 300;
    protected static const HELP_CONTENTS :String = "<b>How to Play</b>\n" +
        "Use the letters along the bottom of the board to make words " +
        "that are at least MINLEN letters long.\n\n" +
        "<font color='#0000ff'><b>Blue</b></font> letters multiply the word score by two.\n" +
        "<font color='#ff0000'><b>Red</b></font> letters multiply the word score by three.\n" +
        "Only one multiplier per word will count.\n\n";

    protected static const HELP_MULTI :String =
        "The first to score POINTS points wins the round.\n\n" +
        "Win ROUNDS rounds to win the game.\n\n" +
        "Click a flying saucer to change a letter into a wildcard (*) if you can't find a word.";

    protected static const HELP_SINGLE :String =
        "Clear the board using long words to get a high score!\n\n" +
        "Click a flying saucer to change a letter into a wildcard (*) if you can't find a word.";
}
}
