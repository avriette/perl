// this is the groundwork for the js message queue event generator for mudra

var fs = require('fs');
var moment = require('moment');

/* CONFIG PARSING  {{{
 *
 *
 */

/* Your sasl.json looks like:
{
	"saslpassword" : "i#like#22/7",
	"saslnick"     : "mudra"
}
*/
var saslconfig = require('./sasl.json');

/* Your mudra.json looks like:
{
	"channels" : [ '##mudra', '#bots' ]
	"showErrors" : true,
	"autoRejoin" : true,
	"autoConnect": true,
	// etc etc etc. See irc.Client() for named parameters.
}
*/
var mudraconfig = require( './mudra.json' );
// XXX: clean this up. hashrefslice or something?
mudraconfig.saslnick = saslconfig.saslnick;
mudraconfig.saslpassword = saslconfig.saslpassword;

/* Your aws.json looks like:
{
	"accessKeyId": "AKadlkjasdlkajsd",
	"secretAccessKey": "adlkjasdlja/slj/qa",
	"region": "us-west-2"
}
*/
var SQS = require('aws-sqs');
awsconfig = require('./aws.json');

// }}}

/* IRC INSTANTIATION {{{
 *
 *
 */

// instantiate the bot
var jsbot = require('jsbot/jsbot');
var instance = jsbot.createJSBot('mudra');

for (net = 0; net <= mudraconfig.length(); net++) {
	instance.addConnection(
		mudraconfig[net].netname,  // e.g., "freenode"
		mudraconfig[net].hostname, // e.g., "irc.freenode.net"
		mudraconfig[net].port,     // e.g., "6667", "+6697"

		// join the channels listed in mudraconfig[net].channels, which looks like:
		// [ "##mudra", "#realitest" ] or just
		// [ "##mudra" ]
		function(event) {
			chans = mudraconfig[net].channels;
			for (chan = 0; chan <= chans.length(); chan++) {
				// is there an event emitted here if the channel is un-joinable etc?
				instance.join(event, chans[chan]);
			}.bind(this);
		}
	);
} // for net


var irc = require('irc');
var client = new irc.Client( 'irc.freenode.net', 'mudra', mudraconfig );

// let's add some event handlers

// catch errors which are otherwise lethal
client.addListener('error', function(message) {
	console.log('error: ', message);
});

// so for now, we're going to write the commands to files so we can compare
// what they look like and get an idea for what they will look like in the
// queue.
//
client.addListener( 'raw', function(message) {
	console.log( 'raw received: ' + message.command + ' ' + message.args );
	var now = moment();
	var dirname = mudraconfig.netname + '/' + message.command;
	var fname   = dirname + '/' + now.unix() + '.' + now.millisecond() + '.json';
	// synchronous mkdir - we are just going to make it each time and
	// ignore the error rather than check for -d or find mkdir -p
	// > In particular, checking if a file exists before opening it is an anti-pattern that leaves you vulnerable to race conditions: another process may remove the file between the calls to fs.exists() and fs.open(). Just open the file and handle the error when it's not there.
	fs.mkdir( './' + mudraconfig.netname + '/' + message.command, '0700', function(err) {
		if (err) {
			// fs: missing callback Error: EEXIST, mkdir './freenode/PING'
			// so, figure out how to catch eexist. some time.
			1;
		}
	});
	fs.writeFile( fname,
		JSON.stringify( message.args, null, '\t' ) + "\n",
		function(err) {
			if(err) {
				console.log(err);
			}
		}
	);
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
	// note that this is async. so if we try to delete it, it may not
	// actually be there already.
	if (err) {
		// something something err
	}
	queues.subscriber = res;
	console.log( 'birthed queue ' + res );
	sqs.deleteQueue( queues.subscriber,  function(err) {
		if (err) {
			// gosh. what happened?
			console.log(err);
		}
		console.log('attempted destruction of queue');
	});
});


// }}}

// jane@cpan.org // vim:tw=80:ts=2:noet
