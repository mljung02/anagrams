#!/usr/bin/env ruby

require_relative 'anagram_client'
require 'zlib'
require "benchmark"
#require 'benchmark/bigo'


FILENAME = 'dictionary.txt.gz'
RESULTS_DIR = 'benchmark_results/'
SLICE_SIZE = 100
MAX_I = 1_000
MAX_J_MULT = 10
INC_I_MULT = 10
INC_J_MULT = 2
POST_BM = false
GET_BM = false
DELETE_BM = true
GET_STATS_BM = true

@client = AnagramClient.new(ARGV)

def data(filename)
	#puts("Creating array...")
	Zlib::GzipReader.open(filename) do |gz|
		gz.read.split("\n")
	end
end

words = data(FILENAME)

# Post Benchmarking
if POST_BM
	puts("<<<<<POST Words Benchmarking>>>>>\nN\tTime")
	run_data = []
	i = 10
	while i <= MAX_I
		j = i
		limit = j * MAX_J_MULT
		while j <= limit
			@client.delete('/words.json') rescue nil

			data = words.sample(j)
			
			time = Benchmark.realtime do
				data.each_slice(SLICE_SIZE) do |slice|
					@client.post('/words.json', nil, {"words" => slice }) rescue nil
				end
			end

			run_data.push([j, time])

			puts("#{j}\t#{time}")

			j = j * INC_J_MULT
		end
		i = i * INC_I_MULT
	end

	file_content = ""
	run_data.each_with_index do |x, xi|
		x.each_with_index do |y, yi|
			file_content = file_content + "#{y}" + ", "
		end
		file_content = file_content.chomp(", ")
		file_content = file_content + "\n"
	end
	File.write(RESULTS_DIR + 'benchmark_post.csv', file_content)
end


# Get Anagram Benchmarking
if GET_BM
	puts("<<<<<GET Anagrams Benchmarking>>>>>\nN\tTime")
	run_data = []
	i = 10
	while i <= MAX_I
		j = i
		limit = j * MAX_J_MULT
		while j <= limit
			@client.delete('/words.json') rescue nil
			
			data = words.sample(j)
			data.each_slice(SLICE_SIZE) do |slice|
				@client.post('/words.json', nil, {"words" => slice }) rescue nil
			end

			time = Benchmark.realtime do
				data.each do |word|
     				 @client.get("/anagrams/#{word}.json")
   				end
			end

			run_data.push([j, time])

			puts("#{j}\t#{time}")

			j = j * INC_J_MULT
		end
		i = i * INC_I_MULT
	end

	file_content = ""
	run_data.each_with_index do |x, xi|
		x.each_with_index do |y, yi|
			file_content = file_content + "#{y}" + ", "
		end
		file_content = file_content.chomp(", ")
		file_content = file_content + "\n"
	end
	File.write(RESULTS_DIR + 'benchmark_get.csv', file_content)
end

# Delete Anagram Benchmarking
if DELETE_BM
	puts("<<<<<DELETE Words Benchmarking>>>>>\nN\tTime")
	run_data = []
	i = 10
	while i <= MAX_I
		j = i
		limit = j * MAX_J_MULT
		while j <= limit
			@client.delete('/words.json') rescue nil
			
			data = words.sample(j)
			data.each_slice(SLICE_SIZE) do |slice|
				@client.post('/words.json', nil, {"words" => slice }) rescue nil
			end

			time = Benchmark.realtime do
				data.each do |word|
     				 @client.delete("/words/#{word}.json")
   				end
			end

			run_data.push([j, time])

			puts("#{j}\t#{time}")

			j = j * INC_J_MULT
		end
		i = i * INC_I_MULT
	end

	file_content = ""
	run_data.each_with_index do |x, xi|
		x.each_with_index do |y, yi|
			file_content = file_content + "#{y}" + ", "
		end
		file_content = file_content.chomp(", ")
		file_content = file_content + "\n"
	end
	File.write(RESULTS_DIR + 'benchmark_delete.csv', file_content)
end

# Get Stats Benchmarking
if GET_STATS_BM
	puts("<<<<<GET Stats Benchmarking>>>>>\nN\tTime")
	run_data = []
	i = 10
	while i <= MAX_I
		j = i
		limit = j * MAX_J_MULT
		while j <= limit
			@client.delete('/words.json') rescue nil
			
			data = words.sample(j)
			data.each_slice(SLICE_SIZE) do |slice|
				@client.post('/words.json', nil, {"words" => slice }) rescue nil
			end

			time = Benchmark.realtime do
     			@client.get("/words/stats.json")
			end

			run_data.push([j, time])

			puts("#{j}\t#{time}")

			j = j * INC_J_MULT
		end
		i = i * INC_I_MULT
	end

	file_content = ""
	run_data.each_with_index do |x, xi|
		x.each_with_index do |y, yi|
			file_content = file_content + "#{y}" + ", "
		end
		file_content = file_content.chomp(", ")
		file_content = file_content + "\n"
	end
	File.write(RESULTS_DIR + 'benchmark_stats.csv', file_content)
end


###################################
# Attempt at using benchmark/bigo
###################################

# Benchmark.bigo do |x|
#   x.generator do |size|
#     data(FILENAME).sample(size)
#   end

#   x.min_size = 10000
#   x.step_size = 10000

#   x.report('POST /words.json') do |array, size|
#     post_dictionary(array)
#   end

#   x.chart! 'chart_anagram_post.html'

#   x.compare!
# end

# Calculating -------------------------------------
# POST /words.json 10000
# /home/kruser/.rbenv/versions/2.4.2/lib/ruby/gems/2.4.0/gems/benchmark-bigo-1.0.0/lib/benchmark/bigo/report.rb:14:in `add_entry': wrong number of arguments (given 5, expected 6) (ArgumentError)
#         from /home/kruser/.rbenv/versions/2.4.2/lib/ruby/gems/2.4.0/gems/benchmark-ips-2.7.2/lib/benchmark/ips/job.rb:345:in `create_report'
#         from /home/kruser/.rbenv/versions/2.4.2/lib/ruby/gems/2.4.0/gems/benchmark-ips-2.7.2/lib/benchmark/ips/job.rb:283:in `block in run_benchmark'
#         from /home/kruser/.rbenv/versions/2.4.2/lib/ruby/gems/2.4.0/gems/benchmark-ips-2.7.2/lib/benchmark/ips/job.rb:239:in `each'
#         from /home/kruser/.rbenv/versions/2.4.2/lib/ruby/gems/2.4.0/gems/benchmark-ips-2.7.2/lib/benchmark/ips/job.rb:239:in `run_benchmark'
#         from /home/kruser/.rbenv/versions/2.4.2/lib/ruby/gems/2.4.0/gems/benchmark-ips-2.7.2/lib/benchmark/ips/job.rb:193:in `block in run'
#         from /home/kruser/.rbenv/versions/2.4.2/lib/ruby/gems/2.4.0/gems/benchmark-ips-2.7.2/lib/benchmark/ips/job.rb:192:in `times'
#         from /home/kruser/.rbenv/versions/2.4.2/lib/ruby/gems/2.4.0/gems/benchmark-ips-2.7.2/lib/benchmark/ips/job.rb:192:in `run'
#         from /home/kruser/.rbenv/versions/2.4.2/lib/ruby/gems/2.4.0/gems/benchmark-bigo-1.0.0/lib/benchmark/bigo.rb:37:in `bigo'
#         from anagram_benchmark.rb:52:in `<main>'

