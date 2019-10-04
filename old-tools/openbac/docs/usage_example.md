#Usage Example

####How to use server.py to integrate your application with openbac.

Currently OpenBAC is written as a library in python.  I have plans to expand and continue writing more libraries in more languages.  However for now, until I at least know that openbac.py is secure (pending code review) this is my focus.

That being said.  It really shouldn't be that big of a deal.  No matter your situation, you should be able to integrate your application with OpenBAC over https on the loopback interface pretty much no matter what.

Let me show you how to do that...

###Example: PHP

Let's say you or your company had a web application.  And let's also say that web application had a section beyond which you could not go unless you were an authenticated user.  You might be tempted to store your passwords like many people do, in a database after one pass of md5 using php's built in md5 function.  

Please don't do that...

Instead here's what you could do to make your application Ball and Chain enabled.  

First, setup your array.  You'll do this by running the script "interactive-generate.py".  It's simple, just follow the prompts.  There's really only one trick with interactive-generate.  At some point it's going to ask you about the length of pointer that you want to use.  This pointerlength is critical.  It is what determines the size of your array.  The script will help you figure it all out.  

What you need to do next is remember the value that you set in the script, then set pointerlengths to that value in openbac.conf.  Once you've done that, go ahead and walk through the rest of openbac.conf making sure that everything is set as you please.  The config file is decently commented, so you shouldn't have any trouble figuring out what everything does.  (And if anything is broken server.py will let you know when you try to launch it.)

Next you'll want to launch server.py, the command for that would look something like:  **`python ./server.py`**

NOTE: server.py is unauthenticated.  So you probably want to have it running on the same server as your web application and only listening on the loopback interface.  You can set this inside openbac.conf

**The API**

Now I don't want to go too in depth about the server.py API.  There is a whole different document `server.md` that you should read if you want to learn more.  

But basically there are only two different calls you need to make to server.py to perform all of the basic functions.  You make these calls over https in the form of a get request... so in the url.

It's super easy.

Again, check out the rest of the documentation to learn exactly how the algorithm works.  But when it comes to integration inside your application all you need to do is (for PHP) something like this: 

```php
		$result = file_get_contents('https://localhost:2337/?mk=userpasswd');
```

There is seriously no excuse for you to not be using this algorithm to protect your users.

1. Build the array with `interactive-generate.py`
2. Check your config (openbac.conf) and set a few values
3. Launch server.py (and set it to launch at boot)
4. Replace your md5() call with a call to server.py 

And your users will be safe(r).
