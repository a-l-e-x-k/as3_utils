package networking.networkers
{
import flash.events.EventDispatcher;

/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public interface INetworker
	{
		/**
		 * Returns id of inviter if user was invited by link to friendly view.game. If not invited via link - "" is returned.
		 */
		function init(flashVars:Object, appID:String = ""):void;
		
		///These may be united in 1 more complicated method///
		/**
		 * Gets name & photo of user who launched the app
		 */
		function getUserData():void;
		
		/**
		 * Gets friends (including inApp friends) of user who launched the app
		 */
		function getUserFriends():void;
		
		/**
		 * Gets links to avatars for desired users. Dispatches through eventDispatcher array of objects (with "uid", "photo" properties)
		 */
		function getAvatarLinks(uidArray:Array):void; 
		
		/**
		 * Gets photo, sex and name for target uid
		 */
		function getPhotoAndSexAndName(userID:String):void;
		
		/**
		 * Gets names & photos for a bunch of users (for TOP100 likes)
		 */
		function getUsersNamesAndPhotos(usersIDS:Array):void;
		
		/**
		 * Gets name (at VK in accusative) and photo of "liker" when showing Like popup
		 */
		function getPhotoAndName(userID:String):void;
		
		/**
		 * At FB user is redirected to Coins purchase HTML page
		 */
		function showCoinAdder():void;
		
		/**
		 * Gets coint amount, price in Social Network Currency
		 */
		function requestOfferData(offerID:int):void;	


		function get coreLink():String;

		/**
		 * Show multi-friend invite popup of social network
		 */
		function showSocialInvitePopup():void;
		
		function getUserAlbums():void;

		function get dispatcher():EventDispatcher;

		function get appID():String;

		function get uid():String;
	}	
}