package networking.networkers
{
import events.RequestEvent;

	import networking.Networking;

	import playerio.Message;

import model.userData.UserData;

import utils.t;

import networking.external.vk.APIConnection;
import networking.external.vk.events.CustomEvent;

/**
 * ...
 *
 * Junkyyyyy... sucks. Refactor it.
 *
 * @author Alexey Kuznetsov
 */
public class VKNetworker extends Networker implements INetworker
{
	public var VK:APIConnection;
	public var offers:Array = [];
	private var _buyingOfferPrice:int;

	public function VKNetworker()
	{
		offers[0] = { coins:300, price:3 };
		offers[1] = { coins:600, price:5 };
		offers[2] = { coins:1250, price:10 };
		offers[3] = { coins:2600, price:20 };
		offers[4] = { coins:6600, price:50 };
		offers[5] = { coins:14000, price:100 };
	}

	public function init(flashVars:Object, appID:String = ""):void
	{
		_appID = appID;
		_uid = flashVars.viewer_id;
		VK = new APIConnection(flashVars);

//			if (flashVars.referrer == "wall_view_inline") Networking.fromWall = true;
//			else //no stats saving when opening app on wall
//			{
//				Misc.delayCallback(function() //connection is null, wait a while
//				{
//					if (flashVars.referrer == "menu") Networking.connection.send("vkr", "menu");
//					else if (flashVars.referrer == "wall_post_inline" || flashVars.referrer == "wall_post") Networking.connection.send("vkr", "wp");
//					else if (flashVars.referrer == "catalog_visitors") Networking.connection.send("vkr", "cat");
//					else if (flashVars.referrer == "featured") Networking.connection.send("vkr", "myapps");
//					else Networking.connection.send("vkr", "l");
//				}, 15000);
//			}

//			var inviterID:String = "";
//			if (flashVars.hash != null && flashVars.hash != "")
//			{
//				inviterID = flashVars.hash.substring(flashVars.hash.indexOf("=") + 1, flashVars.hash.length); //e.g. hash: "roomid=384903248234"
//			}
////			return inviterID;
	}

	public function getUserData():void
	{
		VK.api("getProfiles", { uids:Networking.uid, fields:"photo_medium_rec,first_name" }, function (response:Array)
		{
			//t.obj(response);
			//UserData.saveUserData(response[0].first_name, response[0].photo_medium_rec);
		});
	}

	public function getUserFriends():void
	{
		VK.api("friends.getAppUsers", {}, processInApp);
	}

	private function processInApp(response:Array):void
	{
		//t.obj(response);
		VK.api("friends.get", { uid:Networking.uid, fields:"photo_medium_rec,first_name" }, function (responsee:Array)
		{
			//t.obj(responsee);
			saveFriendsData(response, responsee);
		}, handleVKError);
	}

	private function saveFriendsData(inApp:Array, allFriends:Array):void
	{
		var result:Array = [];
		for (var i:int = 0; i < allFriends.length; i++)
		{
			result.push({ id:allFriends[i].uid, name:allFriends[i].first_name, photoURL:allFriends[i].photo_medium_rec, inApp:inApp.indexOf(allFriends[i].uid) != -1 });
		}
		UserData.friends = result;
	}

	public function getAvatarLinks(uidArray:Array):void
	{
		trace("getAvatarLinks");
		var idsString:String = ""; //TODO: add here an execute method (so when > 1000 wins will be handled by multiple model.requests)
		var count:int = uidArray.length;
		for (var i:int = 0; i < uidArray.length; i++)
		{
			idsString += uidArray[i] + (i == (count - 1) ? "" : ",");
		}
		trace(idsString);
		VK.api("getProfiles", { uids:idsString, fields:"photo_medium_rec" }, saveAvatarsLinks);
	}

	private function saveAvatarsLinks(response:Array):void
	{
		var resultArray:Array = [];
		for (var j:int = 0; j < response.length; j++)
		{
			resultArray[j] = { uid:response[j].uid, photo:response[j].photo_medium_rec };
		}
		_dispatcher.dispatchEvent(new RequestEvent(RequestEvent.AVATARS_LINKS_LOADED, { users:resultArray }));
	}

	public function getPhotoAndSexAndName(userID:String):void
	{
		VK.api("getProfiles", { uids:userID, fields:"photo_medium_rec,sex,first_name" }, savePhotoSexAndName);
	}

	private function savePhotoSexAndName(response:Array):void
	{
		var result:Object = { uid:response[0].uid, photo:response[0].photo_medium_rec, sex:response[0].sex, name:response[0].first_name };
		_dispatcher.dispatchEvent(new RequestEvent(RequestEvent.AVATARS_WITH_SEX_LOADED, result));
	}

	public function getUsersNamesAndPhotos(usersIDS:Array):void
	{
		trace("getUsersNamesAndPhotos");
		//t.obj(usersIDS);
		var idsString:String = "";
		var count:int = usersIDS.length;
		for (var i:int = 0; i < count; i++)
		{
			idsString += usersIDS[i] + (i == (count - 1) ? "" : ",");
		}
		trace("idsString: " + idsString);
		VK.api("getProfiles", { uids:idsString, fields:"first_name, photo_medium_rec" }, saveUsersNames);
	}

	private function saveUsersNames(response:Array):void
	{
		trace("saveUsersNames");
		//t.obj(response);
		var resultArray:Array = [];
		for (var i:int = 0; i < response.length; i++)
		{
			resultArray.unshift({ id:response[i].uid, name:response[i].first_name, photoURL:response[i].photo_medium_rec });
		}
		_dispatcher.dispatchEvent(new RequestEvent(RequestEvent.USERS_INFO_LOADED, { users:resultArray })); //for other classes
	}

	private function dispatchNewPlayerObject(response:Array, playerObj:Object):void
	{
		playerObj.photoURL = response[0].photo_medium_rec;
		playerObj.name = response[0].first_name;
		_dispatcher.dispatchEvent(new RequestEvent(RequestEvent.IMREADY, playerObj));
	}

	public function getPhotoAndName(userID:String):void
	{
		VK.api("getProfiles", { uids:userID, fields:"photo_medium_rec,first_name", name_case:"acc" }, dispatchPhotoAndName);
	}

	private function dispatchPhotoAndName(response:Array):void
	{
		_dispatcher.dispatchEvent(new RequestEvent(RequestEvent.AVATAR_WITH_NAME_LOADED, { name:response[0].first_name, photo:response[0].photo_medium_rec }));
	}

	public function requestOfferData(offerID:int):void
	{
		_buyingOfferPrice = offers[offerID].price; //e.g. 2 votes
		trace("wanna buy: " + offers[offerID].coins + " for: " + _buyingOfferPrice);
//			Networking.connection.send("wv", Networking.flashVars.auth_key, _buyingOfferPrice);
//			Networking.connection.addMessageHandler("notEnough", showSocialNetworkPopup);
//			Networking.connection.addMessageHandler("err", dispatchError);
//			Networking.connection.addMessageHandler("ok", dispatchOK);
	}

	private function showSocialNetworkPopup(message:Message):void
	{
		trace("notEnough: " + message.getInt(0));
		VK.callMethod("showPaymentBox", message.getInt(0));
		VK.addEventListener("onBalanceChanged", onBalanceChanged);
	}

	private function onBalanceChanged(e:CustomEvent):void
	{
		trace("votes added: " + e.params[0]); //votes in sotye doli
//			Networking.connection.send("wv", Networking.flashVars.auth_key, _buyingOfferPrice);
	}

	private function dispatchOK(message:Message):void
	{
		UserData.coins += message.getInt(0);
		removeListeners();
		_dispatcher.dispatchEvent(new RequestEvent(RequestEvent.COINS_ADDED));
	}

	private function dispatchError(message:Message):void
	{
		removeListeners();
		_dispatcher.dispatchEvent(new RequestEvent(RequestEvent.ERROR_AT_ADDING_COINS));
	}

	private function removeListeners():void
	{
//			Networking.connection.removeMessageHandler("notEnough", showSocialNetworkPopup);
//			Networking.connection.removeMessageHandler("err", dispatchError);
//			Networking.connection.removeMessageHandler("ok", dispatchOK);
		VK.removeEventListener("onBalanceChanged", onBalanceChanged);
	}

	public function handleVKError(response:Object):void
	{
//			Networking.client.errorLog.writeError(response.error_msg.toString(), "", "", null);
	}

	public function showCoinAdder():void
	{
		//at Facebook there is page shown to buy coins via JS + HTML. At VK this function ain't called.
	}

	public function showSocialInvitePopup():void
	{
		VK.callMethod("showInviteBox");
	}

	private function checkSettings(mask:int, callback:Function):void
	{
		VK.api("getUserSettings", { }, function (response:int):void //check access rights
		{
			trace("access rights: " + (response & mask).toString());
			if (response & mask)
				requestAlbums();
			else
			{
				VK.callMethod("showSettingsBox", mask); //request photos rights
				VK.addEventListener("onSettingsChanged", callback);
			}
		});
	}

	public function getUserAlbums():void
	{
		_dispatcher.addEventListener(RequestEvent.SETTINGS_SUCCESSFULLY_CHANGED, requestAlbums);
		checkSettings(4, onPhotoSettingsChanged); //4 - photos rights
	}

	private function requestAlbums(e:RequestEvent = null):void
	{
		_dispatcher.removeEventListener(RequestEvent.SETTINGS_SUCCESSFULLY_CHANGED, requestAlbums);
		VK.api("photos.getAlbums", { uid:Networking.uid, need_covers:1 }, onAlbumsLoaded, handleVKError);
	}

	private function onAlbumsLoaded(response:Object):void
	{
		t.obj(response);
		_dispatcher.dispatchEvent(new RequestEvent(RequestEvent.ALBUMS_LOADED, response.response));
	}

	private function onPhotoSettingsChanged(eve:Object):void
	{
		trace("settings changed to: " + eve.params[0]);
		trace("e.params[0] & 4:" + (eve.params[0] & 4).toString());

		VK.removeEventListener("onSettingsChanged", onPhotoSettingsChanged);
		if (eve.params[0] & 4) _dispatcher.dispatchEvent(new RequestEvent(RequestEvent.SETTINGS_SUCCESSFULLY_CHANGED));
		else _dispatcher.dispatchEvent(new RequestEvent(RequestEvent.ALBUM_ERROR));
	}

	public function get coreLink():String
	{
		return "http://vk.com/id"; //link that is used to navigate to profile pages after clicking on avatar
	}
}
}