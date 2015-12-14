// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls {	
	
	import fl.controls.ButtonLabelPlacement;
	import fl.controls.LabelButton;
	import fl.core.UIComponent;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.Shape;
	import Error;

    //--------------------------------------
    //  Styles
    //--------------------------------------
    /**
     *  @copy fl.controls.LabelButton#style:icon
     *
     *  @default null
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="icon", type="Class")]

    /**
     *  @copy fl.controls.LabelButton#style:upIcon
     *
     *  @default CheckBox_upIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="upIcon", type="Class")]

    /**
     *  @copy fl.controls.LabelButton#style:downIcon
     *
     *  @default CheckBox_downIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="downIcon", type="Class")]

    /**
     *  @copy fl.controls.LabelButton#style:overIcon
     *
     *  @default CheckBox_overIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="overIcon", type="Class")]

    /**
     *  @copy fl.controls.LabelButton#style:disabledIcon
     *
     *  @default CheckBox_disabledIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="disabledIcon", type="Class")]

    /**
     *  @copy fl.controls.LabelButton#style:selectedDisabledIcon
     *
     *  @default CheckBox_selectedDisabledIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="selectedDisabledIcon", type="Class")]

    /**
     *  @copy fl.controls.LabelButton#style:selectedUpIcon
     *
     *  @default CheckBox_selectedUpIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="selectedUpIcon", type="Class")]


    /**
     *  @copy fl.controls.LabelButton#style:selectedDownIcon
     *
     *  @default CheckBox_selectedDownIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="selectedDownIcon", type="Class")]

    /**
     *  @copy fl.controls.LabelButton#style:selectedOverIcon
     *
     *  @default CheckBox_selectedOverIcon
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="selectedOverIcon", type="Class")]


    /**
     *  @copy fl.controls.LabelButton#style:textPadding
     *
     *  @default 5
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="textPadding", type="Number", format="Length")]


    //--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 *  The CheckBox component displays a small box that can contain 
	 *  a check mark. A CheckBox component can also display an optional
	 *  text label that is positioned to the left, right, top, or bottom 
	 *  of the CheckBox.
     *
	 *  <p>A CheckBox component changes its state in response to a mouse
	 *  click, from selected to cleared, or from cleared to selected. 
     *  CheckBox components include a set of <code>true</code> or <code>false</code> values
	 *  that are not mutually exclusive.</p>
	 *
     * @includeExample examples/CheckBoxExample.as
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class CheckBox extends LabelButton {
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		private  static var defaultStyles:Object = {icon:null,
												  upIcon:"CheckBox_upIcon",downIcon:"CheckBox_downIcon",overIcon:"CheckBox_overIcon",
												  disabledIcon:"CheckBox_disabledIcon",
												  selectedDisabledIcon:"CheckBox_selectedDisabledIcon",
												  focusRectSkin:null,
												  focusRectPadding:null,
												  selectedUpIcon:"CheckBox_selectedUpIcon",selectedDownIcon:"CheckBox_selectedDownIcon",selectedOverIcon:"CheckBox_selectedOverIcon",
												  textFormat:null,
												  disabledTextFormat:null,
												  embedFonts:null,
												  textPadding:5};
		
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
		public static function getStyleDefinition():Object { return defaultStyles; }


		/**
		 *  @private
		 *  Creates the Accessibility class.
         *  This method is called from UIComponent.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public static var createAccessibilityImplementation:Function;

		/**
         * Creates a new CheckBox component instance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function CheckBox() { 
			super();
		}

		/**
         * A CheckBox toggles by definition, so the <code>toggle</code> property is set to 
         * <code>true</code> in the constructor and cannot be changed for a CheckBox.
         *
         * @default true
		 * 
		 * @throws Error This value cannot be changed for a CheckBox component.
         * 
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get toggle():Boolean {	
			return true;
		}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set toggle(value:Boolean):void {
			throw new Error("Warning: You cannot change a CheckBox's toggle.");
		}
		
		/**
         * A CheckBox never auto-repeats by definition, so the <code>autoRepeat</code> property is set 
         * to <code>false</code> in the constructor and cannot be changed for a CheckBox.
         *
         * @default false
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function get autoRepeat():Boolean { 
			return false;
		}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override public function set autoRepeat(value:Boolean):void {
			return;	
		}	
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function drawLayout():void{
			super.drawLayout();	
			
			var textPadding:Number = Number(getStyleValue("textPadding"));
			switch(_labelPlacement){
				case ButtonLabelPlacement.RIGHT:
					icon.x = textPadding;
					textField.x = icon.x + (icon.width+textPadding);
					background.width = textField.x + textField.width + textPadding;
					background.height = Math.max(textField.height, icon.height)+textPadding*2;
					break;
				case ButtonLabelPlacement.LEFT:
					icon.x = width - icon.width - textPadding;
					textField.x = width - icon.width - textPadding*2 - textField.width;
					background.width = textField.width + icon.width + textPadding*3;
					background.height = Math.max(textField.height, icon.height)+textPadding*2;
					break;
				case ButtonLabelPlacement.TOP:
				case ButtonLabelPlacement.BOTTOM:
					background.width = Math.max(textField.width, icon.width) + textPadding*2;
					background.height = textField.height + icon.height + textPadding*3;
					break;
			}
			background.x = Math.min(icon.x-textPadding, textField.x-textPadding);
			background.y = Math.min(icon.y-textPadding, textField.y-textPadding);
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */				
		override protected function drawBackground():void {
			// do nothing. Checkbox always uses the same empty background.
		}
		
		/**
		 * Shows or hides the focus indicator around this component.
		 *
		 * @param focused Show or hide the focus indicator.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		
		override public function drawFocus(focused:Boolean):void {
			super.drawFocus(focused);
			
			// Size focusRect to fit hitArea, not actual width/height
			if (focused) {
				var focusPadding:Number = Number(getStyleValue('focusRectPadding'));
				uiFocusRect.x = background.x - focusPadding;
				uiFocusRect.y = background.y - focusPadding;
				
				uiFocusRect.width = background.width + (focusPadding<<1);
				uiFocusRect.height = background.height + (focusPadding<<1);
				
			}
		}
		
		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function initializeAccessibility():void {
			if (CheckBox.createAccessibilityImplementation != null) {
				CheckBox.createAccessibilityImplementation(this);
			}
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */		 
		override protected function configUI():void {
			super.configUI();
			super.toggle = true;
			
			var bg:Shape = new Shape();
			var g:Graphics = bg.graphics;
			g.beginFill(0,0);
			g.drawRect(0,0,100,100);
			g.endFill();
			background = bg as DisplayObject;
			addChildAt(background,0);
		}
	}
}