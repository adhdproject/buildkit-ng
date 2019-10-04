#OpenBAC

##Current State of the Project
I have just finished writing the initial version of the library.

It may very well be perfectly secure right now.  But Cryptography is very hard.  If I made even one tiny mistake writing this library, it may end up being insecure.

So, I am currently reviewing this code, and asking that others do the same.  Don't implement this in the wild just yet.  As soon as I think it's safe I will remove this notification.

If you find a bug or security issue in this code contact me on [@zaeyx](https://twitter.com/zaeyx) and I will add you to the list of contributors to this project.  

Thank you.


###Description
This library implements the Ball and Chain algorithm in python.  It comes with some utilities to help you build your Ball and Chain instance.  It also comes with documentation on the inner workings of the algorithm and the library.

You can use the documentation to learn about how it all works.

* docs (folder)

You can use the utils to build your instance

* interactive-generate.py
* server.py
* openbac.conf

You can import the library into your application to string it all together.

* openbac.py


###What is Ball and Chain
Ball and Chain is an algorithm invented by Benjamin Donnelly (@zaeyx) that allows for truly secure password storage.  The main concept behind the algorithm is simple.  With traditional password hashing we take the user's password and send it through a one way hashing function which produces a random output.  The idea is that you cannot look at the output of the function and learn *anything* about the input \(because the function is one way\).  So in order to figure out what user's password is, with access to the hash you would have to guess what the password is and feed that guess through the same function.  If you got the same output you would know what the user's password is.

In this way, we make it very important that users have long and complex passwords.  This makes them very hard to guess.

But times are changing.  Computers are getting faster and faster.  Furthermore, the capabilities of many state and non-state hacker groups are expanding.  The ability of hackers to guess what your password, is rapidly outpacing the computational power of the defenders.

Ball and Chain is an entirely new paradigm.  Without going into the details of the algorithm here, the gist is that Ball and Chain ties authentication to a large file filled with random data.  For the hacker to be able to make a guess as to what the user's password is, they need the user's encrypted password "hash" as well as this large file.  Without the large file, the attackers cannot make even *one* guess.  We make the file so large that it's incredibly hard for the hackers to steal it.  In this way the attackers will not be able to steal your user's passwords, even if they compromise your network.

Now doesn't that sound great?

Dig deeper in the documentation if you want more of an explanation as to how it all works under the hood.  Or simply contact me on Twitter [@zaeyx](https://twitter.com/zaeyx).


