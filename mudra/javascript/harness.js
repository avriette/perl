// this is the groundwork for the js message queue event generator for mudra

var fs = require('fs');
var moment = require('moment');
var mcfg = './mudra.json';

/* CONFIG PARSING  {{{
 *
 *
 */

/* Your mudra.json looks like:
{
	"channels" : [ '##mudra', '#bots' ]
	"showErrors" : true,
	"autoRejoin" : true,
	"autoConnect": true,
	// etc etc etc. See irc.Client() for named parameters.
}
*/
var mudraconfig = function(fname) {
	require( fname );
};

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
var jsbot = require('./jsbot/jsbot');
var instance = jsbot.createJSBot('mudra');

// for (net in Object.keys(mudraconfig('./mudra.json'))) {
for (n = 0; n <= mudraconfig(mcfg).length(); n++) {
	var net = mudraconfig(mcfg)[n];
	console.log(net.netname + ': ' + net.hostname + ':' + net.port);
	instance.addConnection(
		net.netname,  // e.g., "freenode"
		net.hostname, // e.g., "irc.freenode.net"
		net.port,     // e.g., "6667", "+6697"

		// join the channels listed in mudraconfig[net].channels, which looks like:
		// [ "##mudra", "#realitest" ] or just
		// [ "##mudra" ]
		function(event) {
			chans = net.channels;
			for (chan = 0; chan <= chans.length(); chan++) {
				// is there an event emitted here if the channel is un-joinable etc?
				instance.join(event, chans[chan]);
			}
		}.bind(this)
	);
} // for net

// XXX: why do we do this?
instance.ignoreTag('mudra', 'join');

// because rfc 1459 is shitty.
instance.addPreEmitHook(function(event, callback) {
	if(event.user) event.user = event.user.toLowerCase();
	callback(false);
});

// go forth and conquer
instance.connectAll();

// so for now, we're going to write the commands to files so we can compare
// what they look like and get an idea for what they will look like in the
// queue.
//
instance.addListener( 'raw', function(message) {
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
