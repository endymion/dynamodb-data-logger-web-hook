require 'aws-record'

class SignupTable
  include Aws::Record
  if endpoint = ENV['DYNAMODB_ENDPOINT']
    configure_client endpoint: endpoint
  end
  set_table_name ENV['SIGNUPS_TABLE_NAME']
  string_attr :id, hash_key: true
  string_attr :created_at, hash_key: true
  string_attr :body
end

def post(event:,context:)
  item =
    SignupTable.new({
      id: SecureRandom.uuid,
      created_at: Time.now.iso8601,
      body: event["body"]
    })
  item.save!
  { statusCode: 200, body: item.to_s }
end