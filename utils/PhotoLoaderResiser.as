package utils
{
import fl.containers.UILoader;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Dictionary;

import utils.snapshoter.Snapshoter;

/**
	 * Caches loaded images in loadedPictures. Resises loaded pictures, maintaining proportions
	 * @author Alexey Kuznetsov
	 */
	public class PhotoLoaderResiser 
	{
		private static var loadedPictures:Dictionary = new Dictionary(); //UI loaders for each kind of avatar
		
		public static function getPhotoContainer(link:String, height:int, width:int):UILoader
		{
			var avatar:UILoader = new UILoader();			
			if (link != null) 
			{
				if (loadedPictures[link] == null) 
				{
					var loader:Loader = new Loader();
					loader.load(new URLRequest(link));
					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
					loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(evt:Event):void //all that business is to avoid security sandbox violation when loading from some domains without crossdomain.xml. Using not an image but a bytes of it
					{
						var lInfo:LoaderInfo = LoaderInfo(evt.target);
						var ba:ByteArray = lInfo.bytes;
						
						var reloader:Loader = new Loader();
						reloader.loadBytes(ba);
						reloader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
						reloader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
						reloader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(ev:Event):void { reloaderComplete(ev, avatar, link, height, width); } );
					});			
				}
				else
				{
					resizeTillFits(loadedPictures[link], width, height);					
					var pic:Bitmap = Snapshoter.snapshot(loadedPictures[link], width, height);
					pic.name = "pic";
					avatar.addChild(pic);
				}
			}
			resizeTillFits(avatar, width, height);
			return avatar;
		}
		
		private static function resizeTillFits(picture:DisplayObject, desiredWidth:Number, desiredHeight:Number):void
		{
			var currentWidth:Number = picture.width;
			var widthResiseProportion:Number = desiredWidth / currentWidth;
			
			picture.width *= widthResiseProportion;
			picture.height *= widthResiseProportion;
			
			if (picture.height < desiredHeight) 
			{
				var heightResizeProportion:Number = desiredHeight / picture.height;
				picture.width *= heightResizeProportion;
				picture.height *= heightResizeProportion;
			}
		}
		
		private static function reloaderComplete(evt:Event, avatar:UILoader, link:String, desiredWidth:Number, desiredHeight:Number):void
		{
			var imageInfo:LoaderInfo = LoaderInfo(evt.target);
			var bmd:BitmapData = new BitmapData(imageInfo.width,imageInfo.height);
			bmd.draw(imageInfo.loader);
			var resultBitmap:Bitmap = new Bitmap(bmd);
			resizeTillFits(resultBitmap, desiredWidth, desiredHeight);
			avatar.addChild(resultBitmap);	
			loadedPictures[link] = avatar;
		}
		
		private static function securityErrorHandler(e:SecurityErrorEvent):void 
		{
			traceme("SecurityError at loading picture", Relations.MISC_EVENTS);
		}
		
		private static function ioErrorHandler(e:Event):void 
		{
			traceme("IO Error at loading picture", Relations.MISC_EVENTS);
		}		
	}
}