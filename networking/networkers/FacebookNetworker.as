//package networking.networkers
//{
//    import events.RequestEvent;
//
//    import flash.external.ExternalInterface;
//
//    import model.userData.UserData;
//
//    import networking.Networking;
//    import networking.special.SocialPerson;
//    import networking.special.ViralEvent;
//
//    import utils.t;
//
//    /**
//     * ...
//     * @author Alexey Kuznetsov
//     */
//    public final class FacebookNetworker extends Networker implements INetworker
//    {
//        public var offers:Array = [];
//        public var coinsRequested:int = 0;
//
//        public function FacebookNetworker() //1 powerup ~ 9-10 cents
//        {
//            offers[0] = { coins: 300, price: 10 };
//            offers[1] = { coins: 650, price: 20 };
//            offers[2] = { coins: 1650, price: 50 };
//            offers[3] = { coins: 3400, price: 100 };
//            offers[4] = { coins: 6900, price: 200 };
//            offers[5] = { coins: 17500, price: 500 };
//
//            ExternalInterface.addCallback("requestOfferData", requestOfferData);
//        }
//
//        public function init(flashVars:Object, appID:String = ""):void
//        {
//            _appID = appID;
//            trace("initialising with: " + flashVars.fb_application_id);
//            _uid = flashVars.fb_user_id;
//            Facebook.init(flashVars.fb_application_id, null, null, flashVars.fb_access_token);
//            t.obj(flashVars);
//        }
//
//        public function getUserData():void
//        {
//            Facebook.api("/" + Networking.uid + "&fields=first_name", receiveDataFromSocial);
//        }
//
//        private function receiveDataFromSocial(...params):void
//        {
//            t.obj(params);
//            trace(params[0]);
//
//            if (params[0])
//            {
//                UserData.saveUserData(params[0].first_name, getPhotoURLByID(params[0].id));
//            }
//            else
//            {
//                trace("Error while getting social data");
//            }
//        }
//
//        public function getPhotoAndName(userID:String):void
//        {
//            Facebook.api("/" + userID + "&fields=first_name", function (...params):void
//            {
//                _dispatcher.dispatchEvent(new RequestEvent(RequestEvent.AVATAR_WITH_NAME_LOADED, { name: params[0].first_name, photo: getPhotoURLByID(userID) }));
//            });
//        }
//
//        public function getUserFriends():void //get friends & the ones who installed will have "installed" property = true
//        {
//            trace("getting friends for: " + Networking.uid);
//            Facebook.api("/" + Networking.uid + "/friends&fields=installed", receiveFriends);
//        }
//
//        private function receiveFriends(...params):void
//        {
//            trace("receiveFriends");
//            var toLoad:Array = []; //ids of guys whose names should be loaded (loading names of only those friends who installed the app)
//            for each (var friend:Object in params[0])
//            {
//                if (friend.installed) toLoad.push(friend.id);
//            }
//            if (toLoad.length > 0) //if there are inApp friends
//            {
//                _dispatcher.addEventListener(RequestEvent.FRIENDS_LOADED, function (e:RequestEvent):void
//                {
//                    onInAppLoaded(e.stuff.users, params[0]);
//                });
//                getUsersNamesAndPhotos(toLoad);
//            }
//            else
//            {
//                onInAppLoaded(toLoad, params[0]);
//            } //pass empty InApp array & all friends
//        }
//
//        private function onInAppLoaded(inApp:Array, allFriends:Array):void
//        {
//            var levelRequest:String = "";
//
//            for (var i:int = 0; i < allFriends.length; i++) //substitute id-only friends with new objects with name, id, photoUrl & inApp
//            {
//                for (var j:int = 0; j < inApp.length; j++)
//                {
//                    if (((allFriends[i] is SocialPerson) && allFriends[i].uid == inApp[j].uid) ||
//                            ((!(allFriends[i] is SocialPerson)) && allFriends[i].id && allFriends[i].id == inApp[j].uid))
//                    {
//                        allFriends[i] = inApp[j];
//                        levelRequest += inApp[j].uid + ",";
//                    } //app user whose name was loaded
//                }
//            }
//
//            var socPerson:SocialPerson;
//            for (i = 0; i < allFriends.length; i++)
//            {
//                if (!(allFriends[i] is SocialPerson))
//                {
//                    socPerson = new SocialPerson();
//                    socPerson.uid = allFriends[i].id;
//                    socPerson.firstName = "noname";
//                    socPerson.photoURL = getPhotoURLByID(allFriends[i].id);
//                    allFriends[i] = socPerson; //insert default obj
//                }
//            }
//
//            _dispatcher.dispatchEvent(new ViralEvent(ViralEvent.IN_APP_FRIENDS_LOADED, allFriends));
//        }
//
//        public function getUsersNamesAndPhotos(usersIDS:Array):void
//        {
//            trace("getUsersInfo");
//            var resultArray:Array = [];
//            var deletedCount:int = 0; //if guys do not exist counter is incremented
//            t.obj(usersIDS);
//
//            for (var i:int = 0; i < usersIDS.length; i++)
//            {
//                Facebook.api("/" + usersIDS[i].toString() + "&fields=first_name", function (...params):void //need only name & id
//                {
//                    if (params != null && params[0])
//                    {
//                        resultArray.unshift({ id: params[0].id, name: params[0].first_name, photoURL: getPhotoURLByID(params[0].id), inApp: true });
//                    }
//                    else
//                    {
//                        trace("Error while getting social data");
//                        deletedCount++;
//                    }
//                    if ((resultArray.length + deletedCount) == usersIDS.length)
//                    {
//                        _dispatcher.dispatchEvent(new RequestEvent(RequestEvent.USERS_INFO_LOADED, { users: resultArray })); //for other classes
//                        _dispatcher.dispatchEvent(new RequestEvent(RequestEvent.FRIENDS_LOADED, { users: resultArray })); //for onInAppLoaded function
//                    }
//                });
//            }
//        }
//
//        public function getAvatarLinks(usersIDS:Array):void
//        {
//            var resultArray:Array = [];
//            for (var j:int = 0; j < usersIDS.length; j++)
//            {
//                resultArray[j] = { uid: usersIDS[j], photo: getPhotoURLByID(usersIDS[j]) };
//            }
//            _dispatcher.dispatchEvent(new RequestEvent(RequestEvent.AVATARS_LINKS_LOADED, { users: resultArray }));
//        }
//
//        public function getPhotoAndSexAndName(userID:String):void
//        {
//            Facebook.api("/" + userID + "&fields=first_name", function (...params):void
//            {
//                var result:Object = { uid: userID, photo: getPhotoURLByID(userID), sex: 0, name: params[0].first_name }; //don't care about sex on english version
//                _dispatcher.dispatchEvent(new RequestEvent(RequestEvent.AVATARS_WITH_SEX_LOADED, result));
//            });
//        }
//
//        private function getPhotoURLByID(id:String):String
//        {
//            return "https://graph.facebook.external.com/" + id + "/picture";
//        }
//
//        public function showFriendInvite(uid:String):void
//        {
//            Facebook.ui('apprequests', { to: uid, message: "I invite you to play realtime games with social story!" });
//        }
//
//        public function showCoinAdder():void //send to JS -> navigate to "Buy coins" tab
//        {
//            ExternalInterface.call("showTab", "coins");
//        }
//
//        public function requestOfferData(offerID:int):void
//        {
////		coinsRequested = offers[offerID].coins;
////		trace("wanna buy: " + offers[offerID].coins + " for: " + offers[offerID].price);  //e.g. 2 credits
////		Networking.client.payVault.getBuyCoinsInfo(
////				"facebook", //Provider name
////				{                //Purchase arguments
////					coinamount:offers[offerID].coins.toString(),
////					title:offers[offerID].coins.toString() + " Coins",
////					description:offers[offerID].coins.toString() + " Coins in Winner's Way Game",
////					image_url:"https://r.playerio.external.com/r/gameclub-keir6opw40azy8e8klqtia/GameClub%20Facebook%20App/images/coin.gif",
////					product_url:"https://apps.facebook.external.com/winnersway/"
////				},
////				showPayDialog, function (e:PlayerIOError):void
////				{
////					trace("Unable to buy coins", e);
////				}
////		);
//        }
//
//        private function showPayDialog(info:Object):void
//        {
//            t.obj(info);
//            var newInfo:Object = { order_info: info.order_info, purchase_type: info.purchase_type, dev_purchase_params: { 'oscif': true } }; //adding dev_purchase_params & removing "method" property
//            t.obj(newInfo);
//            Facebook.ui('pay', newInfo, onCoinsAdded);
//        }
//
//        private function onCoinsAdded(data:Object):void
//        {
//            if (data.order_id)
//            {
//                trace("Purchase completed!");
//                UserData.coins += coinsRequested;
//                _dispatcher.dispatchEvent(new RequestEvent(RequestEvent.BALANCE_CHANGED));
//            }
//            else
//            {
//                trace("Credits purchase failed");
//            }
//
//            ExternalInterface.call("showTab", "play");
//        }
//
//        public function showSocialInvitePopup():void
//        {
//            //TODO: call tab with "Invite friends"
//        }
//
//        public function getUserAlbums():void
//        {
//        }
//
//        public function get coreLink():String
//        {
//            return "https://www.facebook.external.com/"; //link that is used to navigate to profile pages after clicking on avatar
//        }
//    }
//}