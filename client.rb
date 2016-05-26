require 'uri'
require 'net/http'
require 'json'


SERVICE_URL = "http://localhost:4567/search"
name        = ARGV.shift
uri         = URI.parse(SERVICE_URL)
response    = Net::HTTP.post_form(uri, {"name" => name, "format" => "json"})
response    = JSON.parse(response.body)
puts response["name"] ? "Organization number: #{response['orgnum']}" : response["err"]
