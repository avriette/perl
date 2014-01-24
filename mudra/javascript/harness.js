// this is the groundwork for the js client for mudra

// instantiate the bot
var irc = require('irc');
var client = new irc.Client('irc.freenode.net', 'myNick', {
	channels: ['##mudra'],
});

// let's add some event handlers

// catch errors which are otherwise lethal
client.addListener('error', function(message) {
	console.log('error: ', message);
});

// this is basically like _default from P::C::IRC, right?
client.addListener( 'raw', function(message) {
	

});
