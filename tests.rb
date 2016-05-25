require './app'
require 'test/unit'
require 'rack/test'

set :environment, :test
TEST_DB             = "test.sqlite3.db"
ENV["DATABASE_URL"] = "sqlite3://#{Dir.pwd}/#{TEST_DB}"

class AllabolagAPITest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def teardown
    system "rm -f #{TEST_DB}"
  end

  def test_app
    get "/"
    assert last_response.ok?
    assert_equal "Allabolag API", last_response.body
  end
end
