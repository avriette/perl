// this is the groundwork for the js message queue event generator for mudra

/* Your sasl.json looks like:
{
	"saslpassword" : "i#like#22/7",
	"saslnick"     : "mudra"
}
*/
var config = require('./sasl.json');

// instantiate the bot
var irc = require('irc');
var client = new irc.Client('irc.freenode.net', 'mudra', {
	userName    : 'mudra',
	realName    : 'this gigantic robot kills',
	port        : 6697,
	debug       : true,
	showErrors  : true,
	autoRejoin  : true,
	autoConnect : true,
	channels    : ['##mudra'],
	stripColors : false,
	channelPrefixes : "&#",
	messageSplit : 512,

	// these three lines refer to ssl
	secure      : true,
	selfSigned  : true, // basically give no fucks. it's irc.
	certExpired : true, // basically give no fucks. it's irc.

	// sasl auth -- see above re json file
	sasl        : true,
	userName    : config.saslnick,
	password    : config.saslpassword

	/*
	floodProtection : false,
	floodProtectionDelay : 1000,
	*/

});

// let's add some event handlers

// catch errors which are otherwise lethal
client.addListener('error', function(message) {
	console.log('error: ', message);
});

// the raw listener here can basically be ignored if debug is set to true above.
client.addListener( 'raw', function(message) {
	// console.log( 'raw received: ' + message.command + ' ' + message.args + "\n" );
});
