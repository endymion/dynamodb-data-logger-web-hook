# wireless-social-web-hook
AWS Lambda function written in Ruby for recording API Gateway post request data to DynamoDB.

Development Setup
-----------------

#### Set up environment

These instructions are specifically for setting up this project for development using AWS Cloud9.

##### Create Cloud9 environment

Create a new Cloud9 environment and clone this Git repository to it.  It's simplest if you set it up so that the root of the repository is in ```~/environment``` in the Cloud9 environment.

##### Use NPM to install Node packages

This will install the SAM Launchpad package, used for deployment.

    npm install

##### Use the Bundler gem for Ruby to install Ruby dependencies

    bundle install

##### Install SAM

Using Linuxbrew to install SAM works great on the AWS AMI:

https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install-linux.html

#### Set up local DynamoDB tables

SAM Local is just the application server for running Lambda functions locally.
It doesn't provide other AWS services.  If you want to develop Lambda functions
that use DynamoDB, then you will need [DynamoDB Local](https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/DynamoDBLocal.html).

First, create a network for SAM Local to reach your local DynamoDB:

    docker network create sam-local

Then install and run DynamoDB Local, on that Docker network:

    docker run -d -v "$PWD":/dynamodb_local_db -p 8000:8000 --network sam-local --name dynamodb dynamodb-local

If you have already done that once and downloaded the DynamoDB container before, then you can run the existing container with:

    docker start dynamodb

Once you have DynamoDB running on port 8000, create some tables:

    npm run create-tables

If you need to drop those tables and re-create them, then do this:

    npm run delete-tables

To scan the current contents of your ```payment_requests``` table:

    aws dynamodb scan --endpoint-url http://localhost:8000 --table-name payment_requests

#### Start an HTTP server with SAM Local

Use SAM Local for development:

    sam local start-api -p 8080 --docker-network sam-local

Port 8080 is important if you're using AWS Cloud9.

The ```--env-vars``` parameter loads environment variables from the ```env.json``` file.

The ```-docker-network``` parameter enables it to connect to the DynamoDB container.  SAM Local runs in a container, so without this you can't connect to the database.

Ongoing Development
-------------------

Each subsequent time that you want to spin up a development environment, do this:

#### Start your local DynamoDB service

    docker start dynamodb

This will run a static HTTP server and it will continue running in your terminal.

#### Start an HTTP server with SAM Local

Open another terminal window / tab / screen, and run:

    npm run start

### Shortcut

NPM can spin up a whole development environment for you, including the DynamoDB instance and SAM Local server.  The disadvantage is that the asset server and the SAM Local server both have to run in the background, so you have to stop them by killing them.  Or by running the handy NPM scripts for stopping or restarting.

#### Start

To start a development environment, run:

    npm run development

That will run:

* `npm run dynamodb`
* `npm run start`

#### Stop

To stop those things:

    npm run stop`

#### Reset

To stop and restart everything:

    npm run reset