1. all irc numerics can be represented as json packets that are sent out to the queue.
	* have a process that just sits on irc and spews those json packets back to the message queue.
	* this means for example someone can ctcp and hits a different process than privmsg or names or whatever.
	* this also means that anything that wants to send a privmsg to irc only needs to create a reasonably-formed json packet and send it to the queue via socket.
	* most of this is not going to be sensitive, so we don't even care about ssl.
		* and sensitive parts we can have be specific components (gekko to gox for example) and have those parts use ssl without overburdening the rest of the codebase with security strictures.

* to get around the message queue messages-being-eaten thing, have the mudra connection to the server be independent of the part that spits out messages. so mudra connects to the queue, and connects to irc. this is called the passthrough.

* then there's a pub/sub service that keeps track of who gets what. so mudra pushes messages to the queue, and anyone who wants a given message ("i want numeric 550") sends a message to the publisher saying "hey i want that" and this message includes the name of the queue they will be listening on (or channel or whatever). thenceforth the publisher will push to that queue.

* have a 'tell me when' command that can invoke plugins like
	* tell me when /var/log/system.log matches 'auth_failure'
	* tell me when it's 7:15pm [ via sms etc ]
	* tell me when bitcoin hits $750
with output handlers like 'via sms' or 'via irc on freenode #perl' etc.