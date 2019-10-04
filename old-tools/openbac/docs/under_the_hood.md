#How does Ball and Chain work under the hood?

So the whole idea behind Ball and Chain is that we replace simple one-way hashashing functions with something similar enough that it still works within our current application design paradigm; but that also ties authentication to a large file that cannot be easily removed from the network.

So let's break it down and talk about how each part individually works.  We won't read into the algorithm with a maginifying glass, but we will move down from a 30,000ft view to about 10,000ft.  So please take your seats, and fasten your seatbelts.  Cryptography is quite complex and esoteric, so we will be expecting a little turbulence.

As always, you can contact me on Twitter with and comments, questions or concerns [@zaeyx](https://twitter.com/zaeyx). 

#The "large file" \(array\)

For starters let's talk about this "large file" I tend to refer to it as the "array".  The goal of Ball and Chain is to tie authentication to a titan array that cannot be extracted from the network.  If the file cannot be extracted from the network the attacker is going to have one hell of a time figuring out what user passwords are.  Even if the attacker can get his hands on the stored passwords from the passwords database.  His best bet at being able to unpack the "hashes" \(they're not really hashes per-se, but I use the terminology for simplicty's sake\) is to perform what is known as an offline attack.

###Online Attacks
There are two main categories of password guessing attacks.  The first and probably most common is the online attack.  This is where the attacker uses your application to try and guess a user's password.  For example: if someone tries to break into your Facebook account by guessing your login on the Facebook website.  This would be an online attack since they're using the legitimate infrastructure tied to the password database.  

These attacks are quite common, but they're also really easy to counter.  Since we control the infrastructure over which they occur we can do tons of simle things to keep them from ever being fruitful.  Ball and Chain does not address online attacks.  But we also assume that online attacks are *basically* a solved problem if you write your application well.

###Offline Attacks
Then there is the infamous offline attack.  Offline attacks are far more rare.  But when they do happen, they tend to have massive impact.  An offline attack refers to a situation in which the attacker is able to gain access to the stored password hashes.  The latest hashing algorithms provide reasonable security even in this situation.  But only if implemented correctly, and only if the user chooses a strong password.  The reality is that the vast majority of our users are not picking 50 character passphrases.  They're using simple, easy to guess passwords.

Once the attacker gets access to the password hashes, he is able to download them all on to his machine.  At this point there is nothing we can do to limit his ability to guess what the user's password is.  With an online attack, we might limit him to guesing one password per minute.  With a powerful computer (or even in rare cases, as super computer), and depending on the algorithm chosen, the attacker may be able to make upwards of a trillion guesses per *second*.  

With traditional hashing.  There is very little you can do to defend yourself against this scenario.  The problem arises in the way that password hashing itself works.  If you want to slow down your adversary's ability to make guesses against your hashes, you must us a slower hash.  A hash that takes longer to compute.  And the reality is, that the attacker likely has a tremendous advantage in computational power over you.  Maybe your attacker is a nation state.  Maybe your attacker is a collective of hackers with hundreds of machines.  Maybe your attacker gets bored and dumps the hashes out on the web so that the entire internet can take a shot at cracking them.

We cannot assume that everyone will be able to defend themselves against a super computer in a computational war like this.  And I think the vast majority of information security professionals understand this (even if just subconciously).  The only alternative is to increase the complexity of the plaintext password to make it take longer for the attacker to guess it.  I won't even go into how miserably this approach has failed. 

With Ball and Chain we tie the guess attempt to our array.  Then we make sure the attacker cannot get his hands on the array even if he manages to penetrate our network.  In this way, even if we were dealing with a nation-state adversary.  They cannot take even one guess against our password hashes (stored passwords) ever.

###David & Goliath

Let's talk a little bit about exactly how Ball and Chain scales with the defender.  With traditional password storege mechanisms like (hashing algorithms) md5, sha1, sha256, sha3... etc.  You secure your passwords in a way which scales with the competency of your adversary.  That is, the stronger your adversary, the stronger your algorithm must be, and the more strain it puts on your resources to maintain it.

This means that we run into a computational power war with our adversary, that scales off of his capabilities.  Thats terribly unsustainable.

Ball and Chain is the opposite.  Rather than scaling off of your adversary, it scales off of your infrastructure.  The two variables we want to look at are the size of your array, and the upload speed from your network.  As your company gets larger, and your income expands you may want to purchase more upload bandwidth for your network.  At this point you would also have the money you needed to purchase more storage for a larger array.  The faster your upoad speed, the larger of an array you need.  The slower your upload speed, the smaller of an array your network will require.

This means that your solution scales with you, the defender, rather than with your adversary.  Mom and pop shops can now stand up to organized cybercrime!

###So how does the array work?

The array is the easy part.  It is simply a large collection of random data.  That's it.  We don't want it to be something that can easily be compressed or replicated through other means.  So we just fill the array with random data.  If we used something like a book, the attacker would be able to replicate it by buying the book.  So we use gibberish, forcing the attacker to steal the whole thing.

NOTE:
One obvious issue that pops up from time to time if you decide to create your own array rather than using the utilities provided is that of the PRNG seed.  Whatever you do, make sure you use a cryptographically safe PRNG and **throw away the seed**.  You don't want your adversary being able to re-expand the array from a seed.

#The Password Representation

###So, how do we tie authentication to the array?

It's actually pretty simple.  The basic high level summary is that we use little bits of data from the array as part of our verification process.  We use enough of them every time we authenticate someone that the attacker would not be able to figure out anything without access to the whole array.

###But how does it work technically?

So, rather than using a hashing algorithm, we use an encryption algorithm..  With a hashing algorithm you feed in your password as the input and you get out a random representation.  The function is one-way, so there's no way to lok at the output, and learn anything about the input.

With an encryption algorithm it's a bit more complicated.  Instead of just mapping a simple input to an output in an irreversible way you have a message (plaintext) and a key.  You use these two items to produce a ciphertext that can be reversed back into the original message (plaintext) with the same key.

Now people have used encryption to store passwords before.  But what they'll do is something completely unlike what we're doing here.  They will have a system key, and store the password encrypted as the message.  Then when someone comes to authenticate, they will decrypt the message.  This exposes the password, and has been shown to be ineffective in practice.  Our approach is new.

We use the password as the key, and we encrypt data from the array.  More specifically we encrypt multiple pointer:data pairs.

A pointer is just an address in the array.  The data is 32 bytes (or whatever your current setting is) of data from that point in the array.  We do this a number of times.  For example we might do this ten times.  We pick a random point, grab the data at that point, and save it as a pointer:data pair.  Once we've gathered enough data to feel safe we split all the pairs up and concatenate all the pointers and all the data together in order.

So now we have all the pointers as one bytestream, and all the data as another.  We make sure to keep them in order so we can still pull the pointers apart later.  (This is why the pointer lengths are so important.  You'll see that we're very particular about exactly how long the pointers are in bits, and make sure that it's explicitly stated in the utilities and in the config.  We pull the data apart later bit by bit.)

Once we have these two bytestreams we're good to go.  We hash the data stream with a hashing algorithm (just like what people are using for their passwords now). We keep the pointers as is.  We then concatenate the pointer bytestream, an the hashed data bytestream together, that's our message.  Finally we encrypt all that using our user's password as the key.

The result of our operation will be a random ciphertext that looks just like a hash.  It will also come with an IV (Initialization Vector).  These things can be stored in exactly the same way you would have stored a user's password hash before.  (For example: in a passwd file format.)

NOTE:
The user's password is hashed before it's used as the key.  This isn't really consequential to the security of the algorithm, it's more just to turn the password into something of the proper format.  But you can increase the number of passes here for added security if you wish.

###How do we perform authentication?
Authentication is actually pretty simple too.  The user attempts to authenticate to our application.  To do this, they type in their username and password.  Your application goes and looks up the hash associated with that username in the passwd file (or database, or whatever).  Then your application will either directly call functions from the openbac library, or can use some of the openbac utilities to help (again, depending on your exact setup).  Here's how openbac will open up the hash and determine whether or not the user entered the right password.

To start we take whatever the user typed in, and apply it as the key to the ciphertext "hash".  This will give us a plaintext.  At this time though the plaintext we have just looks like random gibberish.  This is because our pointers and our hashed data both come out as perfectly random.  So we don't know if the user has used the proper password yet, we will need to do a bit more work first.

When we made the password representation we made sure the the pointer lengths were set explicitly in the configuration.  So we can read the first N bytes of the random data before us.  That becomes our pointer bytestream.  We then can split it up by bits to get all the pointers themselves back out.  What remains is the hash of our datastream.  

**Why is it a hash though?  Why not just store the datastream as plaintext?**  That's a good question.  I'm glad I asked.  The datastream itself is supposed to be entirely random.  So it wouldn't be a problem to store it plaintext (as it would still be gibberish).  The trick here is that we use multiple pointers.  The whole point of using multiple pointers is so that the attacker would have to go visit every single point in the array that the pointers reference.  If we only used one pointer for example, if the attacker stole 1/10th of the array, he would statistically be able to make guesses against 1/10th of our user's passwords.  The more pointers, the more of the array he needs.  Until eventually, he needs the entire thing to ever make a single guess.  If we stored the data in plaintext though it would completely undermine this.  The chance of any one pointer:data pair being correct is low unless the user put in the right password.  So if we had the pointer:data pairs in our ciphertext plainly, the attacker would only have to verify any one of them.  By hashing the data, we make sure the attacker needs to retrieve all the pointer:data pairs, then combine all the data together to produce the hash and check his work.

And that's pretty much exactly what we do next.  Now that we have our pointerstream and our hashed datastream, we can go to all the pointer locations in the array and retrieve N number of bytes from each pointer as we did before.  Then we combine all our new data together and hash it.  If the new hash is the same as the hash we pulled from the ciphertext (our hashed datastream) then we know the user typed in the right password.

If it's not.  Then something went wrong.  Specifically, the user typed in the wrong password.  

###In Summary

This complex process allows us the ability to check if the correct password was used if and only if we have access to the array.  Since the array is so large, it is incredibly hard for an attacker to download.  Unlike many other security systems we make no assumption that you will not get compromised.  In fact, we plan ahead for it.  Providing you security even if the attackers havecontrol over your network.  Even if the attackers have full control over the machine with the array on it.  They still can't remove it from the network.  The array is just too large, and it would take too long to download it.  

###Of Course
Obviously this isn't every single little detail about this algorithm.  I'll be working to get more additions to the library, documentation, and utilities to fill out even more knowledge about how and why it works, and to enable easy and secure deployment for anyone.

Check out some of the other documents to learn more.

