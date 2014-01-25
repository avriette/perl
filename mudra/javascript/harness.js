// this is the groundwork for the js message queue event generator for mudra

/*
 *
 * CONFIG PARSING
 *
 */

/* Your sasl.json looks like:
{
	"saslpassword" : "i#like#22/7",
	"saslnick"     : "mudra"
}
*/
var saslconfig = require('./sasl.json');

/* Your aws.json looks like:
{
	"accessKeyId": "AKadlkjasdlkajsd",
	"secretAccessKey": "adlkjasdlja/slj/qa",
	"region": "us-west-2"
}
*/
var SQS = require('aws-sqs');
awsconfig = require('./aws.json');

/* IRC INSTANTIATION {{{
 *
 *
 */

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
	userName    : saslconfig.saslnick,
	password    : saslconfig.saslpassword

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

// }}}

/* AWS SQS INSTANTIATION {{{
 *
 *   (but seriously, fuck amazon's api for sqs.)
 */

// this is aws-sqs, via:
//   https://github.com/onmodulus/aws-sqs
var sqs = new SQS( awsconfig.accessKeyId, awsconfig.secretAccessKey );
var queues = { "subscriber" : "" };
sqs.createQueue( 'psmurf', { }, function(err, res) {
	if (err) {
		// something something err
	}
	queues.subscriber = res;
	console.log( 'birthed queue ' + res );
});

sqs.deleteQueue( queues.subscriber,  function(err) {
	if (err) {
		// gosh. what happened?
		console.log(err);
	}
});

// }}}

// jane@cpan.org // vim:tw=80:ts=2:noet
