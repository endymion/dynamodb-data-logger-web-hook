require 'aws-record'

class SignupTable
  include Aws::Record
  puts "TABLE NAME: " + ENV['SIGNUPS_TABLE_NAME']
  set_table_name ENV['SIGNUPS_TABLE_NAME']
  string_attr :id, hash_key: true
  string_attr :body
end

def post(event:,context:)
  body = event["body"]
  item = SignupTable.new(id: SecureRandom.uuid, body: body)
  item.save! # raise an exception if save fails
  item.to_h
end