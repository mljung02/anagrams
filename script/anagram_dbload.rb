#!/usr/bin/env ruby

require_relative '../test/anagram_client'
require 'zlib'
require "benchmark"


FILENAME = '../test/dictionary.txt.gz'
SLICE_SIZE = 1000

def data(filename)
	puts("Creating array...")
	Zlib::GzipReader.open(filename) do |gz|
		gz.read.split("\n")
	end
end

def post_dictionary(array)
	puts("Posting data to API...")

	@client = AnagramClient.new(ARGV)

	array.each_slice(SLICE_SIZE) do |slice|
		@client.post('/words.json', nil, {"words" => slice }) rescue nil
	end
end

def delete_all()
	@client = AnagramClient.new(ARGV)
	@client.delete('/words.json') rescue nil
end

data = data(FILENAME)
delete_all()
puts Benchmark.measure {post_dictionary(data)}