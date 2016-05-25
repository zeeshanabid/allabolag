require 'rubygems'
require 'data_mapper'
require 'open-uri'

DataMapper::setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/allabolag.sqlite3.db")

class Organization
  include DataMapper::Resource
  property :id,     Serial
  property :name,   String, :required => true
  property :orgnum, String

  validates_length_of     :name, :min => 1
  validates_uniqueness_of :name

  def self.search_on_web(name)
    url      = "http://www.allabolag.se/?what=#{URI.escape(name)}"
    doc      = Nokogiri::HTML(open(url))
    org_elem = doc.css("td.text11grey6").first
    orgnum   = org_elem && org_elem.text =~ /Org\.nummer: (\d+-\d+)/ && $1 || nil
    Organization.new(:name => name, :orgnum => orgnum)
  end

end

DataMapper.finalize
Organization.auto_upgrade!
