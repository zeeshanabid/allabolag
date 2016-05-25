
require 'test/unit'
require 'rack/test'

#TEST_DB             = "test.sqlite3.db"
ENV["DATABASE_URL"] = "sqlite::memory:"

require './app'
set :environment, :test

class FakeOrganization < Organization
  TEST_ORGNUMS = {
    "apoex ab" => "556633-4149",
    "sl"       => "556402-4684",
    "max"      => "556188-7562",
    "no org"   => nil,
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

  def setup
    DataMapper.finalize
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

  def test_search_in_cache
    FakeOrganization::TEST_ORGNUMS.each do |name, orgnum|
      FakeOrganization.create(:name => name, :orgnum => orgnum)
    end

    assert_equal 4, FakeOrganization.all.count

    apoex_org = FakeOrganization.search_in_cache("apoex ab")
    assert_equal "apoex ab", apoex_org.name
    assert_equal "556633-4149", apoex_org.orgnum

    sl_org = FakeOrganization.search_in_cache("sl")
    assert_equal "sl", sl_org.name
    assert_equal "556402-4684", sl_org.orgnum

    max_org = FakeOrganization.search_in_cache("max")
    assert_equal "max", max_org.name
    assert_equal "556188-7562", max_org.orgnum

    no_org = FakeOrganization.search_in_cache("no org")
    assert_equal "no org", no_org.name
    assert_nil no_org.orgnum
  end

  def test_search
    apoex_org = FakeOrganization.search("apoex ab")
    assert_equal "apoex ab", apoex_org.name
    assert_equal "556633-4149", apoex_org.orgnum
    assert_equal 1, FakeOrganization.all.count

    sl_org = FakeOrganization.search("sl")
    assert_equal "sl", sl_org.name
    assert_equal "556402-4684", sl_org.orgnum
    assert_equal 2, FakeOrganization.all.count

    max_org = FakeOrganization.search("max")
    assert_equal "max", max_org.name
    assert_equal "556188-7562", max_org.orgnum
    assert_equal 3, FakeOrganization.all.count

    # should use cache because it has already been created
    sl_org = FakeOrganization.search("sl")
    assert_equal "sl", sl_org.name
    assert_equal "556402-4684", sl_org.orgnum
    assert_equal 3, FakeOrganization.all.count
  end
end
