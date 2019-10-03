#On Password Complexity

Traditional password hashing algorithms require users to use long and complex passwords that are hard to guess.

Ball and Chain does not require this.  Here's why.

With hashing, you take the plaintext password and push it through a one-way function in a process known as "hashing."  This produces a fixed size output known as the hash.  The hashing function is irreversible, which means that when someone looks at the hash they don't learn anything about the input that created that hash.

The only way to figure out what input was used to create that hash is to guess inputs until you get an input that produces the same output.  Once you get an input that produces the same output you know that you have the user's password.  This is typically done in a process called "brute-forcing" although there are a few other ways to go about it.

Brute-force guessing looks something like this.  Try password "a", see if it produces the right output.  If it doesn't try password "b".  Then password "c" and so on and so forth until you either get the answer, or get bored.  This is why everyone makes such a big deal about password complexity.  The longer and harder to guess your password is, the less likely it is to be revealed in the event of a hack.

Ball and Chain is an entirely new paradigm.  It doesn't rely on your users' passwords being long and complex.  The whole point of Ball and Chain is that nobody can check if even one password is correct or not without access to the array.  And since the array is so big, the attacker cannot gain access to it.

This means that your users can use simple and easy to remember passwords if you use Ball and Chain.  Now bear with me.  I know that's quite the statement.  For decades we've been trying to drill it into everyone's heads that the solution to network security is long and complex passwords.  So for me to come here and say that we don't actually need them anymore sounds ridiculous.  I must be forgetting something, right?  I must not be thinking about something.  Surely strong passwords are still necessary.

They're seriously not.  And in all reality, they're a liability.  Strong passwords are hard for users to create and remember.  This means users are more likely to violate opsec when it comes to complex password policies.  They're more likely to write their password down.  Or to use the same password on multiple sites.  Maybe when you force them to change their password they simply modify one characer instead of coming up with an entirely new one.  The point is, long, random, complex passwords and busy/lazy humans do not mesh well.

Yes, there are still some ways that a talented adversary can figure out what your user's password is even with Ball and Chain being used.  Maybe the user types the password into an credential harvester style attack form.  Maybe the attacker gets access to the user's box and installs a keylogger.  

But in both these situations the password's security is not linked to the complexity of the password at all.  It's just, typed in, or stolen from memory, or whatever.  A strong password policy does nothing here.

With Ball and Chain, you can use simple easy to remember passwords.  Which means you users will have no trouble changing them every 30 days or so.  It also means your users won't be writing them down, or using the same password for every site.

Your new, relaxed password policy is going to be a good thing.  I promise.

