namespace :sam do

  desc 'Uses SAM to build the project.'
  task :build do
    system('sam build --base-dir lambda')
  end
  
  desc 'Uses SAM to package the project.'
  task :package do
    system('sam package --s3-bucket dynamodb-data-logger-web-hook --output-template-file packaged-template.yaml')
  end
  
  desc 'Uses SAM to deploy the project.'
  task :deploy do
    system('sam deploy --template-file template.yaml --stack-name dynamodb-data-logger-web-hook-development --template-file packaged-template.yaml --capabilities CAPABILITY_IAM --parameter-overrides Environment=development ProjectName=dynamodb-data-logger-web-hook')
  end

end

namespace :dynamodb do

  desc 'Start the dynamodb-local instance for local development.'
  task :start do
    system('docker start dynamodb')
  end

  desc 'Create the local DynamoDB table for local development.'
  task :create do
    system('aws dynamodb create-table --endpoint-url http://localhost:8000 --table-name dynamodb-data-logger-web-hook-signups --attribute-definitions AttributeName=id,AttributeType=S AttributeName=created_at,AttributeType=S --key-schema AttributeName=id,KeyType=HASH AttributeName=created_at,KeyType=RANGE --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1')
  end

  desc 'Delete the local DynamoDB table.'
  task :delete do
    system('aws dynamodb delete-table --endpoint-url http://localhost:8000 --table-name dynamodb-data-logger-web-hook-signups')
  end
  
  desc 'Scan the table.'
  task :scan do
    system('aws dynamodb scan --endpoint-url http://localhost:8000 --table-name dynamodb-data-logger-web-hook-signups')
  end

end

namespace :server do

  desc 'Start a SAM Local HTTP server for local development.'
  task :start do
    Rake::Task['sam:build'].execute &&
    system('sam local start-api -p 8080 --docker-network sam-local --env-vars=env.json')
  end

end

namespace :develop do

  desc 'Start a local development environment, including both dynamodb-local and SAM Local.'
  task :start do
    Rake::Task['dynamodb:start'].execute
    Rake::Task['server:start'].execute
  end

   desc 'Kill everything.'
   task :stop do
     system('killall sam; killall node')
   end

   desc 'Restart everything.'
   task :restart do
    Rake::Task['develop:stop'].execute
    Rake::Task['develop:start'].execute
   end

end