#!/usr/bin/perl

use v5.18;

use Amazon::SQS::Simple;
use File::Slurp qw{ read_file };

# line one is your access key
# line two is your secret key
my @creds = read_file( 'aws_creds.txt' );

my $access_key = $creds[0]; # AWS Access Key ID
my $secret_key = $creds[1]; # AWS Secret Key

# Create an SQS object
my $sqs = new Amazon::SQS::Simple($access_key, $secret_key);

die "ohnoes!" unless $sqs;

# Create a new queue
my $q = $sqs->CreateQueue('psmurf');

# Send a message
# my $response = $q->SendMessage('Hello world!');

# Send multiple messages
# my @responses = $q->SendMessageBatch(['Hello world', 'Farewell cruel world']);

# Retrieve a message
# my $msg = $q->ReceiveMessage();
# print $msg->MessageBody() # Hello world!

# Delete the message
# $q->DeleteMessage($msg->ReceiptHandle());
# or
# $q->DeleteMessage($msg);

# Delete the queue
$q->Delete();

