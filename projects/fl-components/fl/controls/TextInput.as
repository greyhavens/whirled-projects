// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls {
	
	import fl.controls.TextInput;
	import fl.controls.TextArea;
	import fl.core.InvalidationType;
	import fl.core.UIComponent;
	import fl.events.ComponentEvent;
	import fl.managers.IFocusManager;
	import fl.managers.IFocusManagerComponent;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TextEvent;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
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
	 *  Dispatched when user input changes text in the TextInput component.
     *
	 *  <p><strong>Note:</strong> This event does not occur if ActionScript 
     *  is used to change the text.</p>
	 *
     *  @eventType flash.events.Event.CHANGE
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="change", type="flash.events.Event")]

	/**
	 *  Dispatched when the user presses the Enter key.
     *
     *  @eventType fl.events.ComponentEvent.ENTER
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="enter", type="fl.events.ComponentEvent")]

	/**
	 *  Dispatched when the user inputs text.
     *
     *  @eventType flash.events.TextEvent.TEXT_INPUT
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Event(name="textInput", type="flash.events.TextEvent")]


    //--------------------------------------
    //  Styles
    //--------------------------------------
	/**
	 * The name of the class to use as a background for the TextInput
	 * component.
	 *
     * @default TextInput_upSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="upSkin", type="Class")]
	/**
	 * The padding that separates the component border from the text, in pixels.
	 *
     * @default 0
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="textPadding", type="Number", format="Length")]

	/**
	 * The name of the class to use as a background for the TextInput
     * component when its <code>enabled</code> property is set to <code>false</code>.
	 *
     * @default TextInput_disabledSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	[Style(name="disabledSkin", type="Class")]
	
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
	 * The TextInput component is a single-line text component that
	 * contains a native ActionScript TextField object. 
	 *
	 * <p>A TextInput component can be enabled or disabled in an application.
	 * When the TextInput component is disabled, it cannot receive input 
	 * from mouse or keyboard. An enabled TextInput component implements focus, 
	 * selection, and navigation like an ActionScript TextField object.</p>
	 *
	 * <p>You can use styles to customize the TextInput component by
	 * changing its appearance--for example, when it is disabled.
	 * Some other customizations that you can apply to this component
	 * include formatting it with HTML or setting it to be a
	 * password field whose text must be hidden. </p>
	 *
     * @includeExample examples/TextInputExample.as
     *
     * @see TextArea
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class TextInput extends UIComponent implements IFocusManagerComponent {
		/**
         * A reference to the internal text field of the TextInput component.
         *
         * @includeExample examples/TextInput.textField.1.as -noswf
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
		protected var background:DisplayObject;
		/**
		 * @private (protected)
		 */
		protected var _html:Boolean = false;
		/**
		 * @private (protected)
		 */
		protected var _savedHTML:String;

		
        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private static var defaultStyles:Object = {
												upSkin:"TextInput_upSkin",
												disabledSkin:"TextInput_disabledSkin",
												focusRectSkin:null,
												focusRectPadding:null,
												textFormat:null,
												disabledTextFormat:null,
												textPadding:0,
												embedFonts:false
												  };
        /**
         * @copy fl.core.UIComponent#getStyleDefinition()
         *
		 * @includeExample ../core/examples/UIComponent.getStyleDefinition.1.as -noswf
		 *
         * @see fl.core.UIComponent#getStyle()
         * @see fl.core.UIComponent#setStyle()
         * @see fl.managers.StyleManager
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public static function getStyleDefinition():Object { return defaultStyles; }

		/**
		 *  @private
         *
		 *  The method to be used to create the Accessibility class.
         *  This method is called from UIComponent.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static var createAccessibilityImplementation:Function;		

		/**
         * Creates a new TextInput component instance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function TextInput() { super(); }
		
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
			textField.text = value;
			_html = false;
			invalidate(InvalidationType.DATA);
			invalidate(InvalidationType.STYLES);
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
			updateTextFieldType();
		}		
		
		/**
         * @copy fl.controls.TextArea#imeMode
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		 public function get imeMode():String {
			return _imeMode;
		}		
		/**
		 * @private (protected)
		 */
		public function set imeMode(value:String):void {
			_imeMode = value;
		}
		/**
         * Gets or sets a Boolean value that indicates how a selection is
		 * displayed when the text field does not have focus. 
		 *
		 * <p>When this value is set to <code>true</code> and the text field does 
		 * not have focus, Flash Player highlights the selection in the text field 
		 * in gray. When this value is set to <code>false</code> and the text field 
		 * does not have focus, Flash Player does not highlight the selection in the 
		 * text field.</p>
		 *
         * @default false
         *
         * @includeExample examples/TextInput.setSelection.2.as -noswf
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get alwaysShowSelection():Boolean {
			return textField.alwaysShowSelection;
		}
		/**
		 * @private (setter)
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
		
		[Inspectable(defaultValue=true)]
		/**
		 * Gets or sets a Boolean value that indicates whether the text field 
		 * can be edited by the user. A value of <code>true</code> indicates
		 * that the user can edit the text field; a value of <code>false</code>
		 * indicates that the user cannot edit the text field. 
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
			updateTextFieldType();
		}

		/**
		 * Gets or sets the position of the thumb of the horizontal scroll bar.
         *
         * @default 0
         *
         * @includeExample examples/TextInput.horizontalScrollPosition.1.as -noswf
         *
         * @see #maxHorizontalScrollPosition
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get horizontalScrollPosition():int {
			return textField.scrollH;
		}
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set horizontalScrollPosition(value:int):void {
			textField.scrollH = value;
		}
		
		/**
		 * Gets a value that describes the furthest position to which the text 
		 * field can be scrolled to the right.
         *
         * @default 0
         *
         * @see #horizontalScrollPosition
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get maxHorizontalScrollPosition():int {
			return textField.maxScrollH;
		}

		/**
		 * Gets the number of characters in a TextInput component.
         *
         * @default 0
         *
         * @includeExample examples/TextInput.maxChars.1.as -noswf
         *
         * @see #maxChars
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get length():int {
			return textField.length;
		}

		[Inspectable(defaultValue=0)]
		/**
		 * Gets or sets the maximum number of characters that a user can enter
		 * in the text field.
		 * 
         * @default 0
         *
         * @includeExample examples/TextInput.maxChars.1.as -noswf
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
		
		[Inspectable(defaultValue=false)]
		/**
         * Gets or sets a Boolean value that indicates whether the current TextInput 
		 * component instance was created to contain a password or to contain text. A value of 
		 * <code>true</code> indicates that the component instance is a password text
		 * field; a value of <code>false</code> indicates that the component instance
		 * is a normal text field. 
		 *
         * <p>When this property is set to <code>true</code>, for each character that the
		 * user enters into the text field, the TextInput component instance displays an asterisk.
		 * Additionally, the Cut and Copy commands and their keyboard shortcuts are 
		 * disabled. These measures prevent the recovery of a password from an
		 * unattended computer.</p>
         *
		 * @default false
         *
         * @includeExample examples/TextInput.displayAsPassword.1.as -noswf
         *
         * @see flash.text.TextField#displayAsPassword TextField.displayAsPassword
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
		
		[Inspectable(defaultValue="")]
		/**
		 * Gets or sets the string of characters that the text field accepts from a user. 
		 * Note that characters that are not included in this string are accepted in the 
		 * text field if they are entered programmatically.
		 *
		 * <p>The characters in the string are read from left to right. You can specify a 
		 * character range by using the hyphen (-) character. </p>
		 *
		 * <p>If the value of this property is null, the text field accepts all characters. 
		 * If this property is set to an empty string (""), the text field accepts no characters.</p>
		 *
		 * <p>If the string begins with a caret (^) character, all characters are initially 
		 * accepted and succeeding characters in the string are excluded from the set of 
		 * accepted characters. If the string does not begin with a caret (^) character, 
		 * no characters are initially accepted and succeeding characters in the string 
		 * are included in the set of accepted characters.</p>
		 * 
		 * @default null
         *
         * @see flash.text.TextField#restrict TextField.restrict
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
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
			if (componentInspectorSetting && value == "") { value = null; }
			textField.restrict = value;
		}

		/**
		 * Gets the index value of the first selected character in a selection 
		 * of one or more characters. 
		 *
		 * <p>The index position of a selected character is zero-based and calculated 
		 * from the first character that appears in the text area. If there is no 
		 * selection, this value is set to the position of the caret.</p>
		 *
         * @default 0
         *
         * @includeExample examples/TextInput.selectionBeginIndex.1.as -noswf
         *
         * @see #selectionEndIndex
         * @see #setSelection()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get selectionBeginIndex():int {
			return textField.selectionBeginIndex;
		}

		/**
		 * Gets the index position of the last selected character in a selection 
		 * of one or more characters. 
		 *
		 * <p>The index position of a selected character is zero-based and calculated 
		 * from the first character that appears in the text area. If there is no 
		 * selection, this value is set to the position of the caret.</p>
         *
         * @default 0
         *
         * @see #selectionBeginIndex
         * @see #setSelection()
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get selectionEndIndex():int {
			return textField.selectionEndIndex;
		}

		/**
         * Gets or sets a Boolean value that indicates whether extra white space is
		 * removed from a TextInput component that contains HTML text. Examples 
		 * of extra white space in the component include spaces and line breaks.
		 * A value of <code>true</code> indicates that extra 
		 * white space is removed; a value of <code>false</code> indicates that extra 
		 * white space is not removed.
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
		 }

		/**
		 * Contains the HTML representation of the string that the text field contains.
		 *
         * @default ""
         *
         * @includeExample examples/TextInput.htmlText.1.as -noswf
         *
         * @see #text
         * @see flash.text.TextField#htmlText
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		 public function get htmlText():String {
			return textField.htmlText;
		 }
		 /**
		  * @private (setter)
		  */
		 public function set htmlText(value:String):void {
			if (value == "") { 
				text = "";
				return;
			}
			_html = true;
			_savedHTML = value;
			textField.htmlText = value;
			invalidate(InvalidationType.DATA);
			invalidate(InvalidationType.STYLES);
		 }

		/**
		 * The height of the text, in pixels.
		 *
         * @default 0
         *
         * @see #textWidth
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 *
		 * @internal [kenos] What is the "height" of the text? Is this the vertical size of the text field that contains the text?
		 *                   Same for the textWidth property below.
		 */
		public function get textHeight():Number {
			return textField.textHeight;
		}

		/**
		 * The width of the text, in pixels.
		 *
         * @default 0
         *
         * @includeExample examples/TextInput.textWidth.1.as -noswf
         *
         * @see #textHeight
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function get textWidth():Number {
			return textField.textWidth;
		}

		/**
		 * Sets the range of a selection made in a text area that has focus.
		 * The selection range begins at the index that is specified by the start 
		 * parameter, and ends at the index that is specified by the end parameter.
		 * If the parameter values that specify the selection range are the same,
		 * this method sets the text insertion point in the same way that the 
		 * <code>caretIndex</code> property does.
		 *
		 * <p>The selected text is treated as a zero-based string of characters in which
		 * the first selected character is located at index 0, the second 
		 * character at index 1, and so on.</p>
		 *
		 * <p>This method has no effect if the text field does not have focus.</p>
		 *
		 * @param beginIndex The index location of the first character in the selection.
		 *
         * @param endIndex The index location of the last character in the selection.
         *
		 * @includeExample examples/TextInput.setSelection.1.as -noswf
         * @includeExample examples/TextInput.setSelection.2.as -noswf
		 *
         * @see #selectionBeginIndex
         * @see #selectionEndIndex
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function setSelection(beginIndex:int, endIndex:int):void {
			textField.setSelection(beginIndex, endIndex);
		}

		/**
		 * Retrieves information about a specified line of text.
		 * 
		 * @param lineIndex The line number for which information is to be retrieved.
         *
		 * @includeExample examples/TextInput.getLineMetrics.1.as -noswf
		 *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function getLineMetrics(index:int):TextLineMetrics {
			return textField.getLineMetrics(index);
		}
		
		/**
         * Appends the specified string after the last character that the TextArea 
		 * contains. This method is more efficient than concatenating two strings 
		 * by using an addition assignment on a text property; for example, 
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
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		protected function updateTextFieldType():void {
			textField.type = (enabled && editable) ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
			textField.selectable = enabled;
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
		protected function setEmbedFont() {
			var embed:Object = getStyleValue("embedFonts");
			if (embed != null) {
				textField.embedFonts = embed;
			}	
		}
		
		/**
		 * @private (protected)
		 */
		override protected function draw():void {
			if (isInvalid(InvalidationType.STYLES,InvalidationType.STATE)) {
				drawTextFormat();
				drawBackground();
				
				var embed:Object = getStyleValue('embedFonts');
				if (embed != null) {
					textField.embedFonts = embed;
				}
				
				invalidate(InvalidationType.SIZE,false);
			}
			if (isInvalid(InvalidationType.SIZE)) {
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
		protected function drawBackground():void {
			var bg:DisplayObject = background;
			
			var styleName:String = (enabled) ? "upSkin" : "disabledSkin";
			background = getDisplayObjectInstance(getStyleValue(styleName));
			if (background == null) { return; }
			addChildAt(background,0);
			
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
		protected function drawLayout():void {
			var txtPad:Number = Number(getStyleValue("textPadding"));
			if (background != null) {
				background.width = width;
				background.height = height;
			}
			textField.width = width-2*txtPad;
			textField.height = height-2*txtPad;
			textField.x = textField.y = txtPad;
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
			textField.addEventListener(TextEvent.TEXT_INPUT, handleTextInput, false, 0, true);
			textField.addEventListener(Event.CHANGE, handleChange, false, 0, true);
			textField.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, 0, true);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function setFocus():void {
			stage.focus = textField;
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
			if (event.target == this) {
				stage.focus = textField;
			}
			var fm:IFocusManager = focusManager;
			if (editable && fm) {
				fm.showFocusIndicator = true;
				if (textField.selectable && textField.selectionBeginIndex == textField.selectionBeginIndex) {
					setSelection(0, textField.length);
				}
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
			super.focusOutHandler(event);
			
			if(editable) {
				setIMEMode(false);
			}
		}
	}
}