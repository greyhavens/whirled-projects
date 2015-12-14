package org.papervision3d.view.layer {
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.utils.Dictionary;
	
	import org.papervision3d.core.ns.pv3dview;
	import org.papervision3d.core.render.command.RenderableListItem;
	import org.papervision3d.objects.DisplayObject3D;
	import org.papervision3d.view.Viewport3D;
	import org.papervision3d.view.layer.util.ViewportLayerSortMode;	

	/**
	 * @Author Ralph Hauwert
	 */
	public class ViewportLayer extends Sprite
	{
		use namespace pv3dview;
		
		public var childLayers			:Array;
		protected var viewport			:Viewport3D;
		public var displayObject3D		:DisplayObject3D;
		public var displayObjects		:Dictionary = new Dictionary(true);
		
		public var layerIndex			:Number;
		public var forceDepth			:Boolean = false;
		public var screenDepth			:Number = 0;
		public var weight				:Number = 0;
		public var sortMode				:String = ViewportLayerSortMode.Z_SORT;
		public var dynamicLayer			:Boolean = false;
		public var graphicsChannel		:Graphics;
		
		public function ViewportLayer(viewport:Viewport3D, do3d:DisplayObject3D, isDynamic:Boolean = false)
		{
			super();
			this.viewport = viewport;
			this.displayObject3D = do3d;
			this.dynamicLayer = isDynamic;
			this.graphicsChannel = this.graphics;
			
			
			if(isDynamic){
				this.filters = do3d.filters;
				this.blendMode = do3d.blendMode;
				this.alpha = do3d.alpha;
			}
			
			addDisplayObject3D(do3d);
				
			
			init();
		}
		
		public function addDisplayObject3D(do3d:DisplayObject3D):void{
			displayObjects[do3d] = do3d;
		}
		
		public function removeDisplayObject3D(do3d:DisplayObject3D):void{
			displayObjects[do3d] = null;
		}
		
		public function hasDisplayObject3D(do3d:DisplayObject3D):Boolean{
			return (displayObjects[do3d] != null);
		}
		
		protected function init():void
		{
			childLayers = new Array();
		}
		
		public function getChildLayer(do3d:DisplayObject3D, createNew:Boolean = true, recurse:Boolean = false):ViewportLayer{
			
			do3d = do3d.parentContainer?do3d.parentContainer:do3d;	
			
			var index:Number = childLayerIndex(do3d);
			
			if(index > -1)
				return childLayers[index];
			
			for each(var vpl:ViewportLayer in childLayers){
				var tmpLayer:ViewportLayer = vpl.getChildLayer(do3d, false);
				if(tmpLayer)
					return tmpLayer;
			}	
			
			//no layer found = return a new one
			if(createNew)
				return getChildLayerFor(do3d, recurse);
			else
				return null;
		}
		
		protected function getChildLayerFor(displayObject3D:DisplayObject3D, recurse:Boolean = false):ViewportLayer
		{
			
			if(displayObject3D){
				var vpl:ViewportLayer = new ViewportLayer(viewport,displayObject3D, displayObject3D.useOwnContainer);
				childLayers.push(vpl);
				addChild(vpl);
				
				if(recurse)
					displayObject3D.addChildrenToLayer(displayObject3D, vpl);
				
				return vpl;
			}else{
				trace("Needs to be a do3d");
			}
			return null;
		}
		
		public function childLayerIndex(do3d:DisplayObject3D):Number{
			
			do3d = do3d.parentContainer?do3d.parentContainer:do3d;
			
			for(var i:int=0;i<childLayers.length;i++){
				if(childLayers[i].hasDisplayObject3D(do3d)){
					return i;
				}
			}
			return -1;
		}
		
		public function addLayer(vpl:ViewportLayer):void{
			childLayers.push(vpl);
			addChild(vpl);
		}
		
		public function updateBeforeRender():void{
			clear();
			for each(var vpl:ViewportLayer in childLayers){
				vpl.updateBeforeRender();
			}
		}
		
		public function updateAfterRender():void{
			for each(var vpl:ViewportLayer in childLayers){
				vpl.updateAfterRender();
			}
		}
		
		public function removeLayer(vpl:ViewportLayer):void{
			var index:int = getChildIndex(vpl);
			if(index >-1){
				childLayers.splice(index, 1);
			}
		}
		
		public function removeLayerAt(index:Number):void{
			removeChild(childLayers[index]);
			childLayers.splice(index, 1);
			
		}
		
		public function getLayerObjects(ar:Array = null):Array{
		
			if(!ar)
				ar = new Array();
			
			for each(var do3d:DisplayObject3D in this.displayObjects){
				if(do3d){
					ar.push(do3d);
				}
			}
			
			for each(var vpl:ViewportLayer in childLayers){
				vpl.getLayerObjects(ar);
			}

			return ar;
			
		}
		
		
		
		public function clear():void
		{
				
			/* var vpl:ViewportLayer;
			for each(vpl in childLayers){
				
				vpl.clear();
			} */
			graphicsChannel.clear();
			reset();
		}
		
		protected function reset():void{
			
			if(sortMode == "z" && !forceDepth)
				screenDepth = 0;
				
			this.weight = 0;
			
		}
		
		public function sortChildLayers():void{
			
					
			if(sortMode == ViewportLayerSortMode.Z_SORT){
				childLayers.sortOn("screenDepth", Array.DESCENDING | Array.NUMERIC);
			}else{
				childLayers.sortOn("layerIndex", Array.NUMERIC);
			}
			
			orderLayers();

		}
		
		protected function orderLayers():void{
			//trace("---------", childLayers.length);
			for(var i:int = 0;i<childLayers.length;i++){
				this.setChildIndex(childLayers[i], i);
				childLayers[i].sortChildLayers();
			}
		}
		
		public function processRenderItem(rc:RenderableListItem):void{
			if(!forceDepth){
				this.screenDepth += rc.screenDepth;
				this.weight++;
			}
		}
		
		public function updateInfo():void{
			
			//this.screenDepth /= this.weight;
			
			for each(var vpl:ViewportLayer in childLayers){
				vpl.updateInfo();
				if(!forceDepth){
					this.weight += vpl.weight;
					this.screenDepth += (vpl.screenDepth*vpl.weight);
				}
			}
			
			if(!forceDepth)
				this.screenDepth /= this.weight;		
			
		}
		
		public function removeAllLayers():void{
			for(var i:int=childLayers.length-1;i>=0;i--){
				removeLayerAt(i);
			}
		}
		
	}
}