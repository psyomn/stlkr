require 'stlkr'
require 'open-uri'
require 'digest'
require 'net/http'
require 'yaml'

module Stlkr
# This looks crudy, but it just stores websites in a file as a list. There's no
# point to use a database for something so trivial. The file
# @author psyomn
class Website
  def initialize(url, hash=nil)
    @url = url
    @hashcode = hash
    fetch! if hash.nil?
  rescue SocketError => e
    puts "Could not reach host"
    puts e
  end

  # @return all the website urls, as a list of strings
  def self.all
    ws = Array.new
    hh = self.load_contents
    hh.each do |k,v|
      w = Website.new(k, hh[k][:hashcode])
      ws.push w
    end
    ws
  end

  # @param url is the url to append to the list of sites
  def insert
    cont = Website.load_contents
    cont[@url] = {
      hashcode: @hashcode
    }
    Website.store_contents(cont)
  end

  def self.delete(url)
    cont = Website.load_contents
    cont.delete url
    Website.store_contents(cont)
  end

  def fetch!
    uri = URI(@url)
    contents = Net::HTTP.get(uri)
    @hashcode = Website.hashify(contents)
  end

  def self.hashify(http_contents)
    Digest::MD5.hexdigest http_contents
  end

  def self.load_contents
    cont = self.file_contents(Stlkr::URIFILE)
    YAML.load(cont) || {}
  end

  def self.store_contents(data_h)
    fh = File.open(Stlkr::URIFILE, 'w')
    fh.write(data_h.to_yaml)
    fh.close
  end

  # @param path is the path to the file to read
  # @return a string with the contents of the file
  def self.file_contents(path)
    fh = File.open(path, 'r')
    cont = fh.read
    fh.close
    cont
  end

  def to_s
    "<Website #{@url} #{@hashcode}>"
  end

  attr_accessor :url
  attr_accessor :hashcode

end
end
