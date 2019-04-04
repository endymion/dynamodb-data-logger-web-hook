require 'aws-record'
require 'ap'

class SignupTable
  include Aws::Record
  configure_client endpoint: 'http://dynamodb:8000' if ENV['AWS_SAM_LOCAL']
  set_table_name ENV['SIGNUPS_TABLE_NAME']
  string_attr :id, hash_key: true
  string_attr :created_at, hash_key: true
  string_attr :body
end

def post(event:,context:)
  puts "EVENT: #{event.ai}"
  item =
    SignupTable.new({
      id: SecureRandom.uuid,
      created_at: Time.now.iso8601,
      body: event["body"]
    })
  item.save!
  { statusCode: 200, body: item.to_h.ai }
end