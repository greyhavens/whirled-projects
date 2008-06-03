package org.papervision3d.materials.special {
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.display.BitmapData;
	
	import org.papervision3d.core.render.draw.IParticleDrawer;
	import org.papervision3d.core.render.data.RenderSessionData;
	import org.papervision3d.core.geom.renderables.Particle;
	
	import flash.display.Graphics;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	
	import org.papervision3d.Papervision3D;	

	/**
	 * @author Seb Lee-Delisle
	 * 
	 * version 0.1 of SpriteParticleMaterial that uses a reference to a
	 * library symbol to create a particle.
	 * 
	 */
	public class MovieAssetParticleMaterial extends ParticleMaterial implements IParticleDrawer
	{
		
		
		// TODO create object to store bitmap and spriterectdata (and USECOUNT!!!) for each type of bitmap
		public static var bitmapLibrary : Object = new Object(); 
		public static var spriteRectLibrary : Object = new Object();
		public static var useCount : Object = new Object();
		
		//private var _animated : Boolean; // animated movieclip - FOR FUTURE USE! NOT IMPLEMENTED YET :-) 
		
		private var scaleMatrix:Matrix;
		private var spriteRect:Rectangle;
		private var renderRect:Rectangle; 
		
		public var createUnique : Boolean = false; 
		
		/**
		* The MovieClip that is used as a texture.
		*/
		public var movie :DisplayObject;

		/**
		* A Boolean value that determines whether the MovieClip is transparent. The default value is true, which, 
		* although slower, is usually what you need for particles.
		*/
		public var movieTransparent :Boolean;
		private var movieAsset : Class;
		private var linkageID : String;

		//public var allowAutoResize:Boolean = true; // FOR FUTURE USE! 
		
		
		// __________________________________________________ NEW
		
		/**
		 * A Particle material that is made from a single DisplayObject (Sprite, MovieClip, etc) or a
		 * Class that extends a DisplayObject (ie a library symbol)
		 * 
		 * v0.1 - TODO implement reusable assets in the same way as MovieAssetMaterial
		 * 
		 * @param linkageID		The Library symbol to make the material out of.
		 * @param transparent	[optional] - whether the image is transparent or not
		 * @param animated		[optional] NOT IMPLEMENTED YET! Please do not use!
		 * @param createUnique	If true, we'll make a bitmap especially for use with this instance of the material, otherwise we'll use a cached version (if there is one)
		 * 
		 */

		public function MovieAssetParticleMaterial(linkageID:String, transparent:Boolean = true, animated : Boolean = false, createUnique:Boolean = false)
		{
			super(0,0);
			
			if((Papervision3D.VERBOSE) && (animated)) trace("WARNING animated MovieAssetParticleMaterial not yet implemented"); 
			
			
			this.createUnique = createUnique;
			this.linkageID = linkageID; 
			movieTransparent = transparent; 
			
			
			if((bitmapLibrary[linkageID])&&(!createUnique))
			{
				bitmap = bitmapLibrary[linkageID];
				spriteRect = spriteRectLibrary[linkageID];
				useCount[linkageID]++; 	
			}
			else 
			{
				
				movieAsset  = Class(getDefinitionByName(linkageID)); 
				movie = DisplayObject(new movieAsset()); 
				
				spriteRect = movie.getBounds(movie); 
				
				bitmap = new BitmapData(movie.width, movie.height,movieTransparent, 0x00000000);
				
				if(!createUnique)
				{
					bitmapLibrary[linkageID] = bitmap;
					spriteRectLibrary[linkageID] = spriteRect; 
					useCount[linkageID] = 1; 
				} 
				
				
				
				var m:Matrix = new Matrix(); 
				m.tx = -spriteRect.left;
				m.ty = -spriteRect.top;
				bitmap.draw(movie, m); 
				
			}
			
		
			renderRect = new Rectangle() ;
			
			
			this.scaleMatrix = new Matrix();
		}
		
		override public function drawParticle(particle:Particle, graphics:Graphics, renderSessionData:RenderSessionData):void
		{
			var cullingrect:Rectangle = renderSessionData.viewPort.cullingRectangle;
			renderRect = cullingrect.intersection(particle.renderRect);
			graphics.beginBitmapFill(bitmap, scaleMatrix, false, smooth);
			graphics.drawRect(renderRect.x, renderRect.y, renderRect.width, renderRect.height);
			graphics.endFill();
			renderSessionData.renderStatistics.particles++;
			//trace("drawParticle : ", renderRect, particle.renderRect); 
			
		}
		
		override public function updateRenderRect(particle : Particle) :void
		{
			scaleMatrix.identity();
			
			var renderrect:Rectangle = particle.renderRect; 
			
			scaleMatrix.tx = spriteRect.left; 
			scaleMatrix.ty = spriteRect.top; 
			scaleMatrix.scale(particle.renderScale*particle.size, particle.renderScale*particle.size);
			var osx:Number = scaleMatrix.tx; 
			var osy:Number = scaleMatrix.ty; 
			
			scaleMatrix.translate(particle.vertex3D.vertex3DInstance.x, particle.vertex3D.vertex3DInstance.y); 
			
			
			
			renderrect.x = particle.vertex3D.vertex3DInstance.x+osx;
			renderrect.y = particle.vertex3D.vertex3DInstance.y+osy;
			renderrect.width = particle.renderScale*particle.size*spriteRect.width;
			renderrect.height = particle.renderScale*particle.size*spriteRect.height;
			
			
		}
		
		
		override public function destroy() :void
		{
			super.destroy(); 
			// TODO Implement bitmap count for dictionary bitmaps and smart disposal
			if(createUnique) bitmap.dispose(); 
			else
			{
				useCount[linkageID]--; 
				if(useCount[linkageID]==0)
				{
					bitmapLibrary[linkageID].dispose(); 
					bitmapLibrary[linkageID] = null; 
					spriteRectLibrary[linkageID] = null; 
				
				}
				
				
			}
			
		}
	}
}