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
	fs.mkdir( './' + mudraconfig.netname + '/' + message.command, '0700' );
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
