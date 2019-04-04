# dynamodb-data-logger-web-hook

AWS Lambda function written in Ruby for recording API Gateway post request data to DynamoDB.

This will take anything that you post to it and record it in a DynamoDB table.

This project serves as an example of how to make a serverless microservice with Ruby and AWS Lambda, and how to manage the deployment and the creation of the cloud DynamoDB table using SAM and AWS CloudFormation.

This is also an exmaple of how to do local development using SAM Local and dynamodb-local.

The original motivator for this data logger is that we needed a web hook for capturing data from a third-party data source for our data warehouse.  We don't want to directly connect our data warehouse database to the world through HTTP.  So we use DynamoDB as a dead drop.  This web hook microservice collects the data postings, and ETL code in the data warehouse comes along later and processes the data.

Development Setup
-----------------

#### Set up environment

These instructions are specifically for setting up this project for development using AWS Cloud9.

##### Create Cloud9 environment

Create a new Cloud9 environment and clone this Git repository to it.  It's simplest if you set it up so that the root of the repository is in ```~/environment``` in the Cloud9 environment.

Once you have the project in ```~/environment```, ```cd``` to that directory.

#### You must use the same version of Ruby!

    rvm use 2.5.0 --install

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

    docker run -d -v "$PWD":/dynamodb_local_db -p 8000:8000 --network sam-local --name dynamodb amazon/dynamodb-local

Once you have DynamoDB running on port 8000, create some tables:

    rake dynamodb:create

If you need to drop those tables and re-create them, then do this:

    rake dynamodb:delete

To scan the current contents of your ```dynamodb-data-logger-web-hook-signups``` table:

    rake dynamodb:scan

#### Start an HTTP server with SAM Local

Build, and use SAM Local for development:

    sam build --base-dir lambda && sam local start-api -p 8080 --docker-network sam-local --env-vars env.json

Port 8080 is important if you're using AWS Cloud9.

The ```--env-vars``` parameter loads environment variables from the ```env.json``` file.

The ```-docker-network``` parameter enables it to connect to the DynamoDB container.  SAM Local runs in a container, so without this you can't connect to the database.

Usage
-----

Once you have an HTTP server running, you can send an HTTP request to it:

    curl -A "DataSourceName" -d "param1=value1&param2=value2" -X POST "http://localhost:8080/signups"

If all goes well, it will return 200 response with a JSON representation of the record that it just posted to DynamoDB.

    2019-04-04 21:19:17 127.0.0.1 - - [04/Apr/2019 21:19:17] "POST /signups HTTP/1.1" 200 -
    {"id":"1611588b-24a5-49ff-9d27-be1bc4397d6a","created_at":"2019-04-04T21:19:17+00:00","body":"param1=value1&param2=value2","source":"DataSourceName"}

Note that it stores the `User-Agent` HTTP header as the data source for the record.

You can also bypass the HTTP server and invoke it directly:

    sam build --base-dir lambda && echo "{\"body\":\"TEST\", \"source\": \"DataSourceName\"}" | sam local invoke PostSignup --docker-network sam-local --env-vars=env.json

You won't get an HTTP response.  Instead, you will see the hash that the function returns:

    {"statusCode":200,"body":"{\"id\":\"c094d3e3-e765-4f04-88bc-4c82352f4bd6\",\"created_at\":\"2019-04-04T21:19:46+00:00\",\"body\":\"TEST\",\"source\":\"DataSourceName\"}"}

(The extra whitespace is for formatting, from the Awesome Print gem.)

#### Source tagging

You can provide a `source` parameter and the DynamoDB record will be tagged with it.  You can either provide that parameter as a `?source=` URL parameter, or as one of the event parameters if you're bypassing HTTP.  As demonstrated above.

Deployment
----------

This project uses SAM to deploy to the cloud using AWS CloudFormation.

First, create a bucket for CloudFormation to use during the deployment.

    aws s3api create-bucket --bucket dynamodb-data-logger-web-hook

Then deploy with:

    npm run build && npm run deploy

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

NPM can spin up a whole development environment for you, including the DynamoDB instance and SAM Local server.  The disadvantage is that the SAM Local server has to run in the background, so you have to stop it by killing it.  Or by running the handy NPM scripts for stopping or restarting.

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