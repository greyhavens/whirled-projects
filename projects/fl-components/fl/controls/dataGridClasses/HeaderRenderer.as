// Copyright 2007. Adobe Systems Incorporated. All Rights Reserved.
package fl.controls.dataGridClasses {
	
	import fl.controls.ButtonLabelPlacement;
	import fl.controls.LabelButton;
	import fl.core.UIComponent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	

    //--------------------------------------
    //  Styles
    //--------------------------------------

    /**
     * @copy fl.controls.LabelButton#style:selectedDisabledSkin
     *
     * @default HeaderRenderer_selectedDisabledSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="selectedDisabledSkin", type="Class")]

    /**
     * @copy fl.controls.LabelButton#style:selectedUpSkin
     *
     * @default HeaderRenderer_selectedUpSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="selectedUpSkin", type="Class")]

    /**
     * @copy fl.controls.LabelButton#style:selectedDownSkin
     *
     * @default HeaderRenderer_selectedDownSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="selectedDownSkin", type="Class")]

    /**
     * @copy fl.controls.LabelButton#style:selectedOverSkin
     *
     * @default HeaderRenderer_selectedOverSkin
     *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
     */
    [Style(name="selectedOverSkin", type="Class")]


    //--------------------------------------
    //  Class description
    //--------------------------------------
	/**
	 * The HeaderRenderer class displays the column header for the current 
	 * DataGrid column. This class extends the LabelButton class and adds a 
     * <code>column</code> property that associates the current header with its 
	 * DataGrid column.
     *
     * @see fl.controls.DataGrid DataGrid
     *
	 * @includeExample examples/HeaderRendererExample.as
	 *
     * @langversion 3.0
     * @playerversion Flash 9.0.28.0
	 */
	public class HeaderRenderer extends LabelButton {
		/**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public var _column:uint;

        /**
         * Creates a new HeaderRenderer instance.
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public function HeaderRenderer():void {
			super();
			focusEnabled = false;
		}
		
        /**
         * @private
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		private static var defaultStyles:Object = {
			upSkin: "HeaderRenderer_upSkin",
			downSkin: "HeaderRenderer_downSkin",
			overSkin: "HeaderRenderer_overSkin",
			disabledSkin: "HeaderRenderer_disabledSkin",
			selectedDisabledSkin: "HeaderRenderer_selectedDisabledSkin",
			selectedUpSkin: "HeaderRenderer_selectedUpSkin",
			selectedDownSkin: "HeaderRenderer_selectedDownSkin",
			selectedOverSkin: "HeaderRenderer_selectedOverSkin",
			textFormat: null,
			disabledTextFormat: null,
			textPadding: 5
		};
		
        /**
         * @copy fl.core.UIComponent#getStyleDefinition()
         *
		 * @includeExample ../../core/examples/UIComponent.getStyleDefinition.1.as -noswf
		 *
         * @see fl.core.UIComponent#getStyle()
         * @see fl.core.UIComponent#setStyle()
         * @see fl.managers.StyleManager
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
         */
		public static function getStyleDefinition():Object {
			return defaultStyles;
		}
		
		/**
		 * The index of the column that belongs to this HeaderRenderer instance.
		 * 
		 * <p>You do not need to know how to get or set this property
		 * because it is internal. However, if you create your own  
		 * HeaderRenderer, be sure to expose it; the HeaderRenderer is used  
		 * by the DataGrid to maintain a reference between the header 
		 * and the related DataGridColumn.</p>
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 * @adobe [LM] Added more details.  This *could* be marked (at)private.
		 */
		public function get column():uint {
			return _column;
		}
		
		/**
         * @private (setter)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		public function set column(value:uint):void {
			_column = value;
		}

		/**
         * @private (protected)
         *
         * @langversion 3.0
         * @playerversion Flash 9.0.28.0
		 */
		override protected function drawLayout():void {
			var txtPad:Number = Number(getStyleValue("textPadding"));
			textField.height =  textField.textHeight + 4;
			textField.visible = (label.length > 0);
			var txtW:Number = textField.textWidth + 4;
			var txtH:Number = textField.textHeight + 4;
			var paddedIconW:Number = (icon == null) ? 0 : icon.width + 4;
			var tmpWidth:Number = Math.max(0, Math.min(txtW, width - 2 * txtPad - paddedIconW));
			if (icon != null) {
				icon.x = width - txtPad - icon.width - 2;
				icon.y = Math.round((height - icon.height) / 2);
			}
			textField.width = tmpWidth;
			textField.x = txtPad;
			textField.y = Math.round((height - textField.height) / 2);
			background.width = width;
			background.height = height;
		}
	}
}

