// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls {
	import fl.controls.ScrollBar;
	import fl.controls.UIScrollBar;
	import fl.controls.ScrollPolicy;
	import fl.controls.TextInput; //Only for ASDocs
	import fl.core.InvalidationType;
	import fl.core.UIComponent;
	import fl.events.ComponentEvent;
	import fl.events.ScrollEvent;
	import fl.managers.IFocusManager;
	import fl.managers.IFocusManagerComponent;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.FocusEvent;
	import flash.system.IME;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import flash.ui.Keyboard;

    //--------------------------------------
    //  Events
    //--------------------------------------
	/**
	 * Dispatched when the text in the TextArea component changes.
     *
     * @eventType flash.events.Event.CHANGE
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="change", type="flash.events.Event")]

	/**
	 * Dispatched when the user enters, deletes,
	 * or pastes text into the component.
     *
     * @eventType flash.events.TextEvent.TEXT_INPUT
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="textInput", type="flash.events.TextEvent")]

	/**
	 * Dispatched when the user presses the Enter key while in the component.
     *
     * @eventType fl.events.ComponentEvent.ENTER
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 *
	 * @internal [kenos] Does "in the control" here mean that the control has focus?
	 */
	[Event(name= "enter", type="fl.events.ComponentEvent")]

	/**
	 * Dispatched when the content is scrolled.
     *
     * @eventType fl.events.ScrollEvent.SCROLL
     *
     * @includeExample examples/TextArea.scroll.1.as -noswf
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="scroll", type="fl.events.ScrollEvent")]


    //--------------------------------------
    //  Styles
    //--------------------------------------
	/**
	 * The class that provides the background for the TextArea
	 * component.
	 *
     * @default TextArea_upSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="upSkin", type="Class")]
	/**
	 * The class that provides the background for the TextArea
     * component when its <code>enabled</code> property is set to <code>false</code>.
	 *
     * @default TextArea_disabledSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="disabledSkin", type="Class")]
	/**
	 * The padding that separates the component border from the text, in pixels.
	 *
     * @default 3
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
    [Style(name="textPadding", type="Number", format="Length")]


	/**
     * @copy fl.controls.LabelButton#style:embedFonts
     *
     * @default false
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="embedFonts", type="Boolean")]
	
	//--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * The TextArea component is a multiline text field with a border
	 * and optional scroll bars. The TextArea component supports
     * the HTML rendering capabilities of Adobe Flash Player.
     *
     * @includeExample examples/TextAreaExample.as
     *
     * @see TextInput
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class TextArea extends UIComponent implements IFocusManagerComponent {
		/**
         * A reference to the internal text field of the TextArea component.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var textField:TextField;
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _editable:Boolean = true;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _wordWrap:Boolean = true;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _horizontalScrollPolicy:String = ScrollPolicy.AUTO;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _verticalScrollPolicy:String = ScrollPolicy.AUTO;

		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _horizontalScrollBar:UIScrollBar;
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var _verticalScrollBar:UIScrollBar;
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected var background:DisplayObject;
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
        protected var _html:Boolean = false;
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var _savedHTML:String;
        /**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		protected var textHasChanged:Boolean = false;


        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private static var defaultStyles:Object = {
												upSkin:"TextArea_upSkin",
												disabledSkin:"TextArea_disabledSkin",
												focusRectSkin:null,
												focusRectPadding:null,
												textFormat:null, disabledTextFormat:null,
												textPadding:3,
												embedFonts:false
												};
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected static const SCROLL_BAR_STYLES:Object = {
												downArrowDisabledSkin:"downArrowDisabledSkin",
												downArrowDownSkin:"downArrowDownSkin",
												downArrowOverSkin:"downArrowOverSkin",
												downArrowUpSkin:"downArrowUpSkin",
												upArrowDisabledSkin:"upArrowDisabledSkin",
												upArrowDownSkin:"upArrowDownSkin",
												upArrowOverSkin:"upArrowOverSkin",
												upArrowUpSkin:"upArrowUpSkin",
												thumbDisabledSkin:"thumbDisabledSkin",
												thumbDownSkin:"thumbDownSkin",
												thumbOverSkin:"thumbOverSkin",
												thumbUpSkin:"thumbUpSkin",
												thumbIcon:"thumbIcon",
												trackDisabledSkin:"trackDisabledSkin",
												trackDownSkin:"trackDownSkin",
												trackOverSkin:"trackOverSkin",
												trackUpSkin:"trackUpSkin",
												repeatDelay:"repeatDelay",
												repeatInterval:"repeatInterval"
												};

		/**
         * @copy fl.core.UIComponent#getStyleDefinition()
         *
         * @includeExample ../core/examples/UIComponent.getStyleDefinition.1.as -noswf
         *
         * @see fl.core.UIComponent#getStyle() UIComponent.getStyle() 
         * @see fl.core.UIComponent#setStyle() UIComponent.setStyle()
         * @see fl.managers.StyleManager StyleManager
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static function getStyleDefinition():Object {
			return UIComponent.mergeStyles(defaultStyles, ScrollBar.getStyleDefinition());
		}

		/** 
         * @private (internal)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static var createAccessibilityImplementation:Function;

		/**
         * Creates a new TextArea component instance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function TextArea() { super(); }

		
		/**
         * Gets a reference to the horizontal scroll bar.
         *
         * @see #verticalScrollBar
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get horizontalScrollBar():UIScrollBar { 
			return _horizontalScrollBar;
		}		
		
		/**
         * Gets a reference to the vertical scroll bar.
         *
         * @includeExample examples/TextArea.verticalScrollBar.1.as -noswf
         *
         * @see #horizontalScrollBar
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get verticalScrollBar():UIScrollBar { 
			return _verticalScrollBar;
		}		
		
		
		[Inspectable(defaultValue=true, verbose=1)]
		/**
         * @copy fl.core.UIComponent#enabled
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get enabled():Boolean {
			return super.enabled;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set enabled(value:Boolean):void {
			super.enabled = value;
			mouseChildren = enabled;  //Disables mouseWheel interaction.
			invalidate(InvalidationType.STATE);
		}
		
        [Inspectable(defaultValue="")]
		/**
         * Gets or sets a string which contains the text that is currently in 
		 * the TextInput component. This property contains text that is unformatted 
		 * and does not have HTML tags. To retrieve this text formatted as HTML, use 
		 * the <code>htmlText</code> property.
		 *
		 * @default ""
         *
         * @see #htmlText
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get text():String {
			return textField.text;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set text(value:String):void {
			if (componentInspectorSetting && value == "") {
				return;
			}
			
			textField.text = value;
			_html = false;
			invalidate(InvalidationType.DATA);
			invalidate(InvalidationType.STYLES);			
			textHasChanged = true;
		}

		[Inspectable()]
		/**
         * Gets or sets the HTML representation of the string that the text field contains.
		 *
		 * @default ""
         *
         * @includeExample examples/TextArea.htmlText.1.as -noswf
         * @includeExample examples/TextArea.htmlText.2.as -noswf
         *
         * @see #text
         * @see flash.text.TextField#htmlText TextField.htmlText
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get htmlText():String {
			return textField.htmlText;
		}

		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set htmlText(value:String):void {
			if (componentInspectorSetting && value == "") {
				return;
			}
			if (value == "") { 
				text = "";
				return;
			}
			_html = true;
			_savedHTML = value;
			textField.htmlText = value;
			invalidate(InvalidationType.DATA);
			invalidate(InvalidationType.STYLES);
			textHasChanged = true;
		}
		
		[Inspectable(defaultValue=false)]
		/**
         * Gets or sets a Boolean value that indicates whether extra white space
		 * is removed from a TextArea component that contains HTML text. Examples 
		 * of extra white space in the component include spaces and line breaks. 
		 * A value of <code>true</code> indicates that extra white space is removed; 
		 * a value of <code>false</code> indicates that extra white space is not removed.
		 *
         * <p>This property affects only text that is set by using the <code>htmlText</code> 
		 * property; it does not affect text that is set by using the <code>text</code> property. 
         * If you use the <code>text</code> property to set text, the <code>condenseWhite</code> 
         * property is ignored.</p>
		 *
         * <p>If the <code>condenseWhite</code> property is set to <code>true</code>, you 
		 * must use standard HTML commands, such as &lt;br&gt; and &lt;p&gt;, to place line 
         * breaks in the text field.</p>
         *
		 * @default false
         *
         * @includeExample examples/TextArea.condenseWhite.1.as -noswf
         *
         * @see flash.text.TextField#condenseWhite TextField.condenseWhite
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get condenseWhite():Boolean {
			return textField.condenseWhite;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set condenseWhite(value:Boolean):void {
			textField.condenseWhite = value;
			invalidate(InvalidationType.DATA);
		}
		
		[Inspectable(defaultValue="auto", enumeration="auto,on,off")]
		/**
		 * Gets or sets the scroll policy for the horizontal scroll bar. 
		 * This can be one of the following values:
		 *
		 * <ul>
		 * <li>ScrollPolicy.ON: The horizontal scroll bar is always on.</li>
		 * <li>ScrollPolicy.OFF: The scroll bar is always off.</li>
		 * <li>ScrollPolicy.AUTO: The scroll bar turns on when it is needed.</li>
		 * </ul>
		 *
		 *
         * @default ScrollPolicy.AUTO
         *
         * @includeExample examples/TextArea.horizontalScrollPolicy.1.as -noswf
         *
         * @see #verticalScrollPolicy
         * @see ScrollPolicy
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get horizontalScrollPolicy():String {
			return _horizontalScrollPolicy;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set horizontalScrollPolicy(value:String):void {
			_horizontalScrollPolicy = value;
			invalidate(InvalidationType.SIZE);
		}
		
		[Inspectable(defaultValue="auto", enumeration="auto,on,off")]
		/**
         * Gets or sets the scroll policy for the vertical scroll bar. 
		 * This can be one of the following values:
		 *
		 * <ul>
		 * <li>ScrollPolicy.ON: The scroll bar is always on.</li>
		 * <li>ScrollPolicy.OFF: The scroll bar is always off.</li>
		 * <li>ScrollPolicy.AUTO: The scroll bar turns on when it is needed.</li>
		 * </ul>
		 *
         * @default ScrollPolicy.AUTO
         *
         * @includeExample examples/TextArea.verticalScrollPolicy.1.as -noswf
         *
         * @see #horizontalScrollPolicy
         * @see ScrollPolicy
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get verticalScrollPolicy():String {
			return _verticalScrollPolicy;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set verticalScrollPolicy(value:String):void {
			_verticalScrollPolicy = value;
			invalidate(InvalidationType.SIZE);
		}

		/**
         * Gets or sets the change in the position of the scroll bar thumb, in  pixels, after
		 * the user scrolls the text field horizontally. If this value is 0, the text
		 * field was not horizontally scrolled.
		 *
         * @default 0
         *
         * @see #verticalScrollPosition
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get horizontalScrollPosition():Number {
			return textField.scrollH;
		}

		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set horizontalScrollPosition(value:Number):void {
			// We must force a redraw to ensure that the size is up to date.
			drawNow();
			textField.scrollH = value;
		}

		/**
         * Gets or sets the change in the position of the scroll bar thumb, in  pixels, after
		 * the user scrolls the text field vertically. If this value is 1, the text
		 * field was not vertically scrolled.
         *
         * @default 1
         *
         * @includeExample examples/TextArea.verticalScrollPosition.1.as -noswf
         *
         * @see #horizontalScrollPosition
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get verticalScrollPosition():Number {
			return textField.scrollV;
		}

		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set verticalScrollPosition(value:Number):void {
			// We must force a redraw to ensure that the size is up to date.
			drawNow();
			textField.scrollV = value;
		}

		/**
		 * Gets the width of the text, in pixels.
		 *
         * @default 0
         *
         * @includeExample examples/TextArea.textHeight.1.as -noswf
         *
         * @see #textHeight
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 *
		 * @internal [kenos] Is this actually the width of the text field that contains the text?
		 *                   The length of the line that is used to format the text? Similar comment for the below.
		 */
		public function get textWidth():Number {
			drawNow();
			return textField.textWidth;
		}

		/**
		 * Gets the height of the text, in pixels.
		 *
         * @default 0
         *
         * @includeExample examples/TextArea.textHeight.1.as -noswf
         *
         * @see #textWidth
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get textHeight():Number {
			drawNow();
			return textField.textHeight;
		}

		/**
		 * Gets the count of characters that the TextArea component contains.
		 *
         * @default 0
         *
         * @see #maxChars
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get length():Number {
			return textField.text.length;
		}
		
        [Inspectable(defaultValue="")]
		/**
         * Gets or sets the string of characters that the text field  
		 * accepts from a user. 
		 *
		 * <p>Note that characters that are not included in this string 
		 * are accepted in the text field if they are entered programmatically.</p>
		 *
		 * <p>The characters in the string are read from left to right. You can 
		 * specify a character range by using the hyphen (-) character. </p>
         *
         * <p>If the value of this property is <code>null</code>, the text field 
		 * accepts all characters. If this property is set to an empty string (""), 
		 * the text field accepts no characters. </p>
		 *
         * <p>If the string begins with a caret (^) character, all characters 
         * are initially accepted and succeeding characters in the string 
         * are excluded from the set of accepted characters. If the string 
         * does not begin with a caret (^) character, no characters are 
         * initially accepted and succeeding characters in the string are 
         * included in the set of accepted characters.</p>
		 *
		 * @default null
         *
         * @see flash.text.TextField#restrict TextField.restrict
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 *
		 * @internal [kenos] Peter, I don't understand the last paragraph above -- re the carets -- but,
		 * if you understand it and think it is clear, it's probably  just that I'm not
		 * well enough acquainted with the use of the property.
		 */
		public function get restrict():String {
			return textField.restrict;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		public function set restrict(value:String):void {
			if (componentInspectorSetting && value == "") { 
				value = null;
			}
			textField.restrict = value;
		}
		
		[Inspectable(defaultValue=0)]
		/**
		 * Gets or sets the maximum number of characters that a user can enter
		 * in the text field.
		 * 
         * @default 0
         *
         * @includeExample examples/TextArea.maxChars.1.as -noswf
         *
         * @see #length
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get maxChars():int {
			return textField.maxChars;
		}

		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set maxChars(value:int):void {
			textField.maxChars = value;	
		}

		/**
         * Gets the maximum value of the <code>horizontalScrollPosition</code> property.
		 * 
         * @default 0
         *
         * @see #horizontalScrollPosition
         * @see #maxVerticalScrollPosition
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get maxHorizontalScrollPosition():int {
			return textField.maxScrollH;
		}

		/**
         * Gets the maximum value of the <code>verticalScrollPosition</code> property.
         *
         * @default 1
         *
         * @see #verticalScrollPosition
         * @see #maxHorizontalScrollPosition
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get maxVerticalScrollPosition():int {
			return textField.maxScrollV;
		}
		
        [Inspectable(defaultValue="true")]
		/**
		 * Gets or sets a Boolean value that indicates whether the text
		 * wraps at the end of the line. A value of <code>true</code> 
		 * indicates that the text wraps; a value of <code>false</code>
		 * indicates that the text does not wrap. 
         *
         * @default true
         *
         * @see flash.text.TextField#wordWrap TextField.wordWrap
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		public function get wordWrap():Boolean {
			return _wordWrap;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set wordWrap(value:Boolean):void {
			_wordWrap = value;
			invalidate(InvalidationType.STATE);
		}
		
		/**
		 * Gets the index position of the first selected character in a selection of one or more
		 * characters. 
		 *
		 * <p>The index position of a selected character is zero-based and calculated
		 * from the first character that appears in the text area. If there is no selection, 
		 * this value is set to the position of the caret.</p>
		 * 
         * @default 0
		 *
		 * @see #selectionEndIndex
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 * 
		 */
		public function get selectionBeginIndex():int {
			return textField.selectionBeginIndex;
		}
		
		/**
		 * Gets the index position of the last selected character in a selection of one or more
		 * characters. 
		 *
		 * <p>The index position of a selected character is zero-based and calculated
		 * from the first character that appears in the text area. If there is no selection, 
		 * this value is set to the position of the caret.</p>
		 * 
         * @default 0
		 *
		 * @see #selectionBeginIndex
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 *
		 */
		public function get selectionEndIndex():int {
			return textField.selectionEndIndex;
		}
		
		/**
         * Gets or sets a Boolean value that indicates whether the TextArea component 
		 * instance is the text field for a password. A value of <code>true</code>
		 * indicates that the current instance was created to contain a password;
		 * a value of <code>false</code> indicates that it was not. 
		 *
		 * <p>If the value of this property is <code>true</code>, the characters 
		 * that the user enters in the text area cannot be seen. Instead,
		 * an asterisk is displayed in place of each character that the
		 * user enters. Additionally, the Cut and Copy commands and their keyboard
		 * shortcuts are disabled to prevent the recovery of a password from
		 * an unattended computer.</p>
         *
         * @default false
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		public function get displayAsPassword():Boolean {
			return textField.displayAsPassword;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set displayAsPassword(value:Boolean):void {
			textField.displayAsPassword = value;
		}
		
        [Inspectable(defaultValue=true)]
		/**
		 * Gets or sets a Boolean value that indicates whether the user can
		 * edit the text in the component. A value of <code>true</code> indicates
		 * that the user can edit the text that the component contains; a value of <code>false</code>
		 * indicates that it cannot. 
		 *
         * @default true
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		public function get editable():Boolean {
			return _editable;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set editable(value:Boolean):void {
			_editable = value;
			invalidate(InvalidationType.STATE);
		}
		
		/**
         * Gets or sets the mode of the input method editor (IME). The IME makes
		 * it possible for users to use a QWERTY keyboard to enter characters from 
		 * the Chinese, Japanese, and Korean character sets.
		 *
		 * <p>Flash sets the IME to the specified mode when the component gets focus, 
		 * and restores it to the original value after the component loses focus. </p>
		 *
		 * <p>The flash.system.IMEConversionMode class defines constants for 
         * the valid values for this property. Set this property to <code>null</code> to 
		 * prevent the use of the IME with the component.</p>
		 * 
         * @see flash.system.IMEConversionMode
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		 public function get imeMode():String {
			return IME.conversionMode;
		 }
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set imeMode(value:String):void {
			_imeMode = value;
		}
		

		/**
		 * Gets or sets a Boolean value that indicates whether Flash Player
		 * highlights a selection in the text field when the text field 
		 * does not have focus. 
		 *
		 * If this value is set to <code>true</code> and the text field does not
		 * have focus, Flash Player highlights the selection in gray. If this value 
		 * is set to <code>false</code> and the text field does not have focus, Flash 
		 * Player does not highlight the selection.  
		 *
		 * @default false
		 *
         * @see flash.text.TextField#alwaysShowSelection TextField.alwaysShowSelection
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get alwaysShowSelection():Boolean {
			return textField.alwaysShowSelection;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set alwaysShowSelection(value:Boolean):void {
			textField.alwaysShowSelection = value;	
		}
		
		/**
         * @copy fl.core.UIComponent#drawFocus()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function drawFocus(draw:Boolean):void {
			if (focusTarget != null) {
				focusTarget.drawFocus(draw);
				return;
			}
			super.drawFocus(draw);
   	 	}
		
		/**
         * Retrieves information about a specified line of text.
		 * 
		 * @param lineIndex The line number for which information is to be retrieved.
		 * 
         * @default null
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function getLineMetrics(lineIndex:int):TextLineMetrics {
			return textField.getLineMetrics(lineIndex);
		}
		
		/**
		 * Sets the range of a selection made in a text area that has focus.
		 * The selection range begins at the index that is specified by the start 
		 * parameter, and ends at the index that is specified by the end parameter.
		 * The selected text is treated as a zero-based string of characters in which
		 * the first selected character is located at index 0, the second 
		 * character at index 1, and so on.
		 *
		 * <p>This method has no effect if the text field does not have focus.</p>
		 *
		 * @param setSelection The index location of the first character in the selection.
		 * @param endIndex The index position of the last character in the selection.
         * 
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 *
		 * @internal Doc team changed the first param name from beginIndex to setSelection
		 *           to temporarily resolve the conflict between param descriptions and
		 *           method signature.
		 */
		public function setSelection(setSelection:int, endIndex:int):void {
			textField.setSelection(setSelection, endIndex);
		}
		
		/**
         * Appends the specified string after the last character that the TextArea 
		 * component contains. This method is more efficient than concatenating two strings 
		 * by using an addition assignment on a text property--for example, 
		 * <code>myTextArea.text += moreText</code>. This method is particularly
		 * useful when the TextArea component contains a significant amount of
		 * content. 
         *
         * @param text The string to be appended to the existing text.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function appendText(text:String):void {
			textField.appendText(text);
			invalidate(InvalidationType.DATA);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function configUI():void {
			super.configUI();
			tabChildren = true;

			textField = new TextField();
			addChild(textField);
			updateTextFieldType();
			
			_verticalScrollBar = new UIScrollBar();
			_verticalScrollBar.name = "V";
			_verticalScrollBar.visible = false;
			_verticalScrollBar.focusEnabled = false;
			copyStylesToChild(_verticalScrollBar, SCROLL_BAR_STYLES);
			_verticalScrollBar.addEventListener(ScrollEvent.SCROLL,handleScroll,false,0,true);
			addChild(_verticalScrollBar);
			
			_horizontalScrollBar = new UIScrollBar();
			_horizontalScrollBar.name = "H";
			_horizontalScrollBar.visible = false;
			_horizontalScrollBar.focusEnabled = false;
			_horizontalScrollBar.direction = ScrollBarDirection.HORIZONTAL;
			copyStylesToChild(_horizontalScrollBar, SCROLL_BAR_STYLES);
			_horizontalScrollBar.addEventListener(ScrollEvent.SCROLL,handleScroll,false,0,true);
			addChild(_horizontalScrollBar);
			
			textField.addEventListener(TextEvent.TEXT_INPUT, handleTextInput, false, 0, true);
			textField.addEventListener(Event.CHANGE, handleChange, false, 0, true);
			textField.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, 0, true);
			
			_horizontalScrollBar.scrollTarget = textField;
			_verticalScrollBar.scrollTarget = textField;
			addEventListener(MouseEvent.MOUSE_WHEEL, handleWheel, false, 0, true);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function updateTextFieldType():void {
			textField.type = (enabled && _editable) ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			textField.selectable = enabled;
			textField.wordWrap = _wordWrap;
			textField.multiline = true;
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleKeyDown(event:KeyboardEvent):void {
			if (event.keyCode == Keyboard.ENTER) {
				dispatchEvent(new ComponentEvent(ComponentEvent.ENTER, true));
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleChange(event:Event):void {
			event.stopPropagation(); // so you don't get two change events
			dispatchEvent(new Event(Event.CHANGE, true));
			invalidate(InvalidationType.DATA);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleTextInput(event:TextEvent):void {
			event.stopPropagation();
			dispatchEvent(new TextEvent(TextEvent.TEXT_INPUT, true, false, event.text));
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleScroll(event:ScrollEvent):void {
			dispatchEvent(event);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function handleWheel(event:MouseEvent):void {
			if (!enabled || !_verticalScrollBar.visible) { return; }
			_verticalScrollBar.scrollPosition -= event.delta * _verticalScrollBar.lineScrollSize;
			dispatchEvent(new ScrollEvent(ScrollBarDirection.VERTICAL, event.delta * _verticalScrollBar.lineScrollSize, _verticalScrollBar.scrollPosition));
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function setEmbedFont() {
			var embed:Object = getStyleValue("embedFonts");
			if (embed != null) {
				textField.embedFonts = embed;
			}	
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function draw():void {
			if (isInvalid(InvalidationType.STATE)) {
				updateTextFieldType();
			}
			
			if (isInvalid(InvalidationType.STYLES)) {
				setStyles();				
				setEmbedFont();				
			}
			
			if (isInvalid(InvalidationType.STYLES, InvalidationType.STATE)) {
				drawTextFormat();
				drawBackground();
				invalidate(InvalidationType.SIZE, false);
			}
			
			if (isInvalid(InvalidationType.SIZE, InvalidationType.DATA)) {
				drawLayout();
			}
			
			
			super.draw();
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function setStyles():void {
			copyStylesToChild(_verticalScrollBar, SCROLL_BAR_STYLES);
			copyStylesToChild(_horizontalScrollBar, SCROLL_BAR_STYLES);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawTextFormat():void {
			// Apply a default textformat
			var uiStyles:Object = UIComponent.getStyleDefinition();
			var defaultTF:TextFormat = enabled ? uiStyles.defaultTextFormat as TextFormat : uiStyles.defaultDisabledTextFormat as TextFormat;
			textField.setTextFormat(defaultTF);
			
			var tf:TextFormat = getStyleValue(enabled?"textFormat":"disabledTextFormat") as TextFormat;
			if (tf != null) {
				textField.setTextFormat(tf);
			} else {
				tf = defaultTF;
			}
			textField.defaultTextFormat = tf;
			
			setEmbedFont();
			if (_html) { textField.htmlText = _savedHTML; }
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawBackground():void {
			var bg:DisplayObject = background;
			var styleName:String = (enabled) ? "upSkin" : "disabledSkin";
			background = getDisplayObjectInstance(getStyleValue(styleName));
			if (background != null) {
				addChildAt(background, 0);
			}
			if (bg != null && bg != background && contains(bg)) { 
				removeChild(bg); 
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function drawLayout():void {
			var txtPad:Number = Number(getStyleValue("textPadding"));
			textField.x = textField.y = txtPad;
			background.width = width;
			background.height = height;

			// Figure out which scrollbars we need:
			var availHeight:Number = height;
			var vScrollBar:Boolean = needVScroll();
			var availWidth:Number = width - (vScrollBar?_verticalScrollBar.width:0);
		
			var hScrollBar:Boolean = needHScroll();
			if (hScrollBar) {
				availHeight -= _horizontalScrollBar.height;
			}			
			setTextSize(availWidth, availHeight, txtPad);
			
			// catch the edge case of the horizontal scroll bar necessitating a vertical one:
			if (hScrollBar && !vScrollBar && needVScroll()) {
				vScrollBar = true;
				availWidth -= _verticalScrollBar.width;
				setTextSize(availWidth, availHeight, txtPad);
			}

			// Size and move the scrollBars
			if (vScrollBar) {
				_verticalScrollBar.visible = true;
				_verticalScrollBar.x = width - _verticalScrollBar.width;
				_verticalScrollBar.height = availHeight;
				_verticalScrollBar.visible = true;
				_verticalScrollBar.enabled = enabled;
			} else {
				_verticalScrollBar.visible = false;
			}
			
			if (hScrollBar) {
				_horizontalScrollBar.visible = true;
				_horizontalScrollBar.y = height - _horizontalScrollBar.height;
				_horizontalScrollBar.width = availWidth;
				_horizontalScrollBar.visible = true;
				_horizontalScrollBar.enabled = enabled;
			} else {
				_horizontalScrollBar.visible = false;
			}
			
			updateScrollBars();	
			
			addEventListener(Event.ENTER_FRAME, delayedLayoutUpdate, false, 0, true);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function delayedLayoutUpdate(event:Event):void {
			if (textHasChanged) {
				textHasChanged = false;
				drawLayout();
				return;
			}
			removeEventListener(Event.ENTER_FRAME, delayedLayoutUpdate);
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function updateScrollBars() {
			_horizontalScrollBar.update();
			_verticalScrollBar.update();
			_verticalScrollBar.enabled = enabled;
			_horizontalScrollBar.enabled = enabled;
			_horizontalScrollBar.drawNow();
			_verticalScrollBar.drawNow();			
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function needVScroll():Boolean {
			if (_verticalScrollPolicy == ScrollPolicy.OFF) { return false; }
			if (_verticalScrollPolicy == ScrollPolicy.ON) { return true; }
			return (textField.maxScrollV > 1);
		}
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function needHScroll():Boolean {
			if (_horizontalScrollPolicy == ScrollPolicy.OFF) { return false; }
			if (_horizontalScrollPolicy == ScrollPolicy.ON) { return true; }
			return (textField.maxScrollH > 0);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function setTextSize(width:Number, height:Number, padding:Number):void {
			var w:Number = width - padding*2;
			var h:Number = height - padding*2;
			
			if (w != textField.width) {
				textField.width = w;
			}
			if (h != textField.height) {
				textField.height = h
			}			
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function isOurFocus(target:DisplayObject):Boolean {
			return target == textField || super.isOurFocus(target);
		}
				
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function focusInHandler(event:FocusEvent):void {
			setIMEMode(true);
						
			if (event.target == this) {
				stage.focus = textField;
			}
			var fm:IFocusManager = focusManager;
			if (fm) {
				if(editable) {
					fm.showFocusIndicator = true;
				}
				fm.defaultButtonEnabled = false;
			}
			super.focusInHandler(event);
			
			if(editable) {
				setIMEMode(true);
			}
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function focusOutHandler(event:FocusEvent):void {
			var fm:IFocusManager = focusManager;
			if (fm) {
				fm.defaultButtonEnabled = true;
			}
			setSelection(0, 0);
			super.focusOutHandler(event);
			
			if(editable) {
				setIMEMode(false);
			}
		}

	}

}
