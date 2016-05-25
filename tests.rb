require './app'
require 'test/unit'
require 'rack/test'

set :environment, :test
TEST_DB             = "test.sqlite3.db"
ENV["DATABASE_URL"] = "sqlite3://#{Dir.pwd}/#{TEST_DB}"

class FakeOrganization < Organization
  TEST_ORGNUMS = {
    "apoex ab" => "556633-4149",
    "sl"       => "556402-4684",
    "max"      => "556188-7562"
  }
  # mock search on web
  def self.search_on_web(name)
    Organization.new(:name => name, :orgnum => TEST_ORGNUMS[name])
  end
end

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

  def test_search_on_web
    apoex_org = FakeOrganization.search_on_web("apoex ab")
    assert_equal "apoex ab", apoex_org.name
    assert_equal "556633-4149", apoex_org.orgnum

    sl_org = FakeOrganization.search_on_web("sl")
    assert_equal "sl", sl_org.name
    assert_equal "556402-4684", sl_org.orgnum

    max_org = FakeOrganization.search_on_web("max")
    assert_equal "max", max_org.name
    assert_equal "556188-7562", max_org.orgnum
  end
end
