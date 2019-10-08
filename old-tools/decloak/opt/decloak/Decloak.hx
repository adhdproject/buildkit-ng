class Decloak {
	static function main() {
		var myURL:String = flash.Lib.current.loaderInfo.url;
		//var regex:EReg = new EReg("^http://(.*?)/", "i");
		//regex.match(myURL);
		//var myBase:String = regex.matched(1); 

		var mySession:String	 = flash.Lib.current.loaderInfo.parameters.cid;
		var myPort:Int		 = Std.parseInt(flash.Lib.current.loaderInfo.parameters.port);
		var myClient:String	 = flash.Lib.current.loaderInfo.parameters.client;
		var myCallback:String	 = flash.Lib.current.loaderInfo.parameters.hook;

		trace(myURL);
		//trace(myBase);
		//flash.Lib.trace(myBase);
		trace(myPort);
		//flash.Lib.trace(myPort);

		var socket:flash.net.XMLSocket = new flash.net.XMLSocket();

		var connectHandler = function( event:flash.events.Event ):Void {
			trace("FLASH: CONNECTED");
			//flash.Lib.trace("FLASH: CONNECTED");
			event.target.send(mySession + ':' + myClient + "\n");
		}

		var dataHandler = function( event:flash.events.DataEvent ):Void {
			if(myCallback.length > 0) {
				new flash.net.URLRequest('javascript:'+myCallback+'("'+event.data+'");');
			}
		}

		var closeHandler = function( event:flash.events.Event ):Void {
			trace("FLASH: CLOSED");
			//flash.Lib.trace("FLASH: CLOSED");
		}

		var securityHandler = function( event:flash.events.SecurityErrorEvent ):Void {
			trace("FLASH: FAILED - SECURITY ERROR");
		}

		socket.addEventListener("connect", connectHandler);
		socket.addEventListener("data", dataHandler);
		socket.addEventListener("close", closeHandler);
		socket.addEventListener("securityError", securityHandler);

		//trace(flash.system.Security.sandboxType);
		//flash.Lib.trace(flash.system.Security.sandboxType);
		
		trace("FLASH: CONNECTING...");
		//flash.Lib.trace("FLASH: CONNECTING...");
		//socket.connect( myBase, myPort );
		// null needs to be changed to the dnsreflector server if it is different from the server hosting this flash
		socket.connect( null, myPort );
	}
}
