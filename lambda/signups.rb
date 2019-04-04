require 'aws-record'

class SignupTable
  include Aws::Record
  set_table_name ENV['SIGNUPS_TABLE_NAME']
  # Use a local DynamoDB instance if running in SAM Local.
  configure_client endpoint: 'http://dynamodb:8000' if ENV['AWS_SAM_LOCAL']
  
  # Attributes.
  string_attr :id, hash_key: true
  string_attr :created_at, hash_key: true
  string_attr :source
  string_attr :body
end

def post(event:nil, context:nil)
  data = {
      # A composite primary key for the DynamoDB table.
      id: SecureRandom.uuid,
      created_at: Time.now.iso8601,
      # The HTTP POST request body.
      body: event['body']
    }
    
  # Tag it with the "?source=" URL parameter, if present.
  if source = event.dig('source') ||
    event.dig('queryStringParameters', 'source') ||
    event.dig('headers', 'User-Agent')
    data['source'] = source
  end
  
  # Create the DynamoDB record from the data.
  record = SignupTable.new(data)
  record.save!
  
  # Return a JSON representation of that record.
  { statusCode: 200, body: record.to_h.to_json }
end