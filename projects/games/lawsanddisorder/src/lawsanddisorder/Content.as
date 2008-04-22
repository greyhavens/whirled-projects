package lawsanddisorder {

import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.AntiAliasType;

/**
 * Static helper functions for defining styles common to multiple components.
 */
public class Content
{
	/**
	 * Build and return a new text field with default style and format.
	 * If percentSize is given, the font will default to that percentage of the default
	 * font size.
	 */
	public static function defaultTextField (percentSize :Number = 1, align :String = "center") :TextField
	{
		var field :TextField = new TextField();
		field.defaultTextFormat = defaultTextFormat(percentSize, align);
		field.antiAliasType = AntiAliasType.ADVANCED;
		field.embedFonts = true;
        field.mouseEnabled = false;
        field.wordWrap = true;
		
		return field;
	}
	
	/**
	 * Build and return a new text format with default settings
	 */
	protected static function defaultTextFormat (percentSize :Number, align :String) :TextFormat
	{
		var format :TextFormat = new TextFormat();
        format.align = align;
		format.font = "lawsfont";
		format.size = Math.round(10 * percentSize);
		format.bold = true;
		
		return format;
	}
	
	/** Embed the font used for everything */
    [Embed(source="../../rsrc/TrajanDark.ttf", fontFamily="lawsfont")]
    protected static var LAWS_FONT :Class;
	
    [Embed(source="../../rsrc/symbols.swf#monieback")]
    public static const MONIE_BACK :Class;
    
    [Embed(source="../../rsrc/symbols.swf#cardback")]
    public static const CARD_BACK :Class;
}
}