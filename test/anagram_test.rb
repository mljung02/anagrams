#!/usr/bin/env ruby

require 'json'
require_relative 'anagram_client'
require 'test/unit'

# capture ARGV before TestUnit Autorunner clobbers it

class TestCases < Test::Unit::TestCase

  # runs before each test
  def setup
    @client = AnagramClient.new(ARGV)

    slice = ["read", "dear", "dare"]
    # add words to the dictionary
    @client.post('/words.json', nil, {"words" => slice }) rescue nil
  end

  # runs after each test
  def teardown
    # delete everything
    @client.delete('/words.json') rescue nil
  end

###############################################################
# Ibotta provided tests
###############################################################
  def test_adding_words
    res = @client.post('/words.json', nil, {"words" => ["read", "dear", "dare"] })

    assert_equal('201', res.code, "Unexpected response code")
  end

  def test_fetching_anagrams
    #pend # delete me

    # fetch anagrams
    res = @client.get('/anagrams/read.json')

    assert_equal('200', res.code, "Unexpected response code")
    assert_not_nil(res.body)

    body = JSON.parse(res.body)

    assert_not_nil(body['anagrams'])

    expected_anagrams = %w(dare dear)
    assert_equal(expected_anagrams, body['anagrams'].sort)
  end

  def test_fetching_anagrams_with_limit
    #pend # delete me

    # fetch anagrams with limit
    res = @client.get('/anagrams/read.json', 'limit=1')

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    assert_equal(1, body['anagrams'].size)
  end

  def test_fetch_for_word_with_no_anagrams
    #pend # delete me

    # fetch anagrams with limit
    res = @client.get('/anagrams/zyxwv.json')

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    assert_equal(0, body['anagrams'].size)
  end

  def test_deleting_all_words
    #pend # delete me

    res = @client.delete('/words.json')

    assert_equal('204', res.code, "Unexpected response code")

    # should fetch an empty body
    res = @client.get('/anagrams/read.json')

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)
  
  puts(body['anagrams'])

    assert_equal(0, body['anagrams'].size)
  end

  def test_deleting_all_words_multiple_times
    # pend # delete me

    3.times do
      res = @client.delete('/words.json')

      assert_equal('204', res.code, "Unexpected response code")
    end

    # should fetch an empty body
    res = @client.get('/anagrams/read.json', 'limit=1')

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    assert_equal(0, body['anagrams'].size)
  end

  def test_deleting_single_word
    # pend # delete me

    # delete the word
    res = @client.delete('/words/dear.json')

    assert_equal('204', res.code, "Unexpected response code")

    # expect it not to show up in results
    res = @client.get('/anagrams/read.json')

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    assert_equal(['dare'], body['anagrams'])
  end

###############################################################
# Additional tests
###############################################################
  def test_fetching_stats_median_between_indices
    #pend
    
    # post more words to data store
    res = @client.post('/words.json', nil, {"words" => ["it", "cat", "act"] })

    # fetch stats
    res = @client.get('/words/stats.json')

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    assert_equal(6, body['count'])

    expected_length = {"average"=>3.33,"max"=>4,"median"=>3.5,"min"=>2}

    assert_equal(expected_length, body['length'])
  end

  def test_fetching_stats_median_at_index
    #pend
    
    # post more words to data store
    res = @client.post('/words.json', nil, {"words" => ["it", "cat", "act", "happy"] })

    res = @client.get('/words/stats.json')

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    assert_equal(7, body['count'])

    expected_length = {"average"=>3.57,"max"=>5,"median"=>4.0,"min"=>2}

    assert_equal(expected_length, body['length'])
  end

  def test_fetching_stats_after_word_delete
    #pend
    
    # post more words to data store
    res = @client.post('/words.json', nil, {"words" => ["it", "cat", "act", "happy"] })
    # delete one word
    res = @client.delete('/words/happy.json')

    # fetch stats
    res = @client.get('/words/stats.json')

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    assert_equal(6, body['count'])

    expected_length = {"average"=>3.33,"max"=>4,"median"=>3.5,"min"=>2}

    assert_equal(expected_length, body['length'])
  end

  def test_fetching_stats_after_word_and_anagrams_delete
    #pend
    
    # post more words to data store
    res = @client.post('/words.json', nil, {"words" => ["it", "cat", "act", "happy"] })
    # delete one word
    res = @client.delete('/words/read/anagrams.json')

    # fetch stats
    res = @client.get('/words/stats.json')

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    assert_equal(4, body['count'])

    expected_length = {"average"=>3.25,"max"=>5,"median"=>2.0,"min"=>2}

    assert_equal(expected_length, body['length'])
  end

  def test_fetching_most_anagrams_1_set
    #pend
    
    # post more words to data store
    res = @client.post('/words.json', nil, {"words" => ["it", "cat", "act", "happy"] })

    res = @client.get('/sets/anagrams/size/max.json')

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    expected_sets = [{"anagrams"=>[%w(read dear dare)], "size"=>3}]

    expected_sets.zip(body['sets']).each do |expected, actual|
      (expected["anagrams"].sort).zip(actual["anagrams"].sort).each do |expected_anagrams, actual_anagrams|
        assert_equal(expected_anagrams.sort, actual_anagrams.sort)
      end
      assert_equal(expected["size"], actual["size"])
    end
  end

  def test_fetching_most_anagrams_2_sets
    #pend
    
    # post more words to data store
    res = @client.post('/words.json', nil, {"words" => ["it", "cat", "act", "tac", "happy"] })

    res = @client.get('/sets/anagrams/size/max.json')

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    expected_sets = [{"anagrams"=>[["read", "dear", "dare"], ["cat", "act", "tac"]], "size"=>3}]
    
    expected_sets.zip(body['sets']).each do |expected, actual|
      (expected["anagrams"].sort).zip(actual["anagrams"].sort).each do |expected_anagrams, actual_anagrams|
        assert_equal(expected_anagrams.sort, actual_anagrams.sort)
      end
      assert_equal(expected["size"], actual["size"])
    end
  end

  def test_fetching_anagrams_of_size
    #pend
    
    # post more words to data store
    res = @client.post('/words.json', nil, {"words" => ["it", "cat", "act", "happy"] })

    res = @client.get('/sets/anagrams/size/2.json')

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    expected_sets = [{"anagrams"=>[%w(act cat)], "size"=>2}, {"anagrams"=>[%w(read dear dare)], "size"=>3}]

    expected_sets.zip(body['sets']).each do |expected, actual|
      (expected["anagrams"].sort).zip(actual["anagrams"].sort).each do |expected_anagrams, actual_anagrams|
        assert_equal(expected_anagrams.sort, actual_anagrams.sort)
      end
      assert_equal(expected["size"], actual["size"])
    end
  end

  def test_fetching_anagrams_of_size_from_max
    #pend
    
    # post addtional words
    res = @client.post('/words.json', nil, {"words" => ["it", "cat", "act", "happy"] })

    res = @client.get('/sets/anagrams/size/-2.json')

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    expected_sets = [{"anagrams"=>[%w(act cat)], "size"=>2}, {"anagrams"=>[%w(read dear dare)], "size"=>3}]

    expected_sets.zip(body['sets']).each do |expected, actual|
      (expected["anagrams"].sort).zip(actual["anagrams"].sort).each do |expected_anagrams, actual_anagrams|
        assert_equal(expected_anagrams.sort, actual_anagrams.sort)
      end
      assert_equal(expected["size"], actual["size"])
    end
  end

  def test_fetching_anagrams_with_propernouns
    #pend
    
    # post more words to data store
    res = @client.post('/words.json', nil, {"words" => ["Drae"] })

    res = @client.get('/anagrams/read.json')

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    expected = {"anagrams"=>["Drae", "dear", "dare"]}

    assert_equal(expected["anagrams"].sort, body["anagrams"].sort)
  end

  def test_fetching_anagrams_no_propernouns
    #pend
    
    # post more words to data store
    res = @client.post('/words.json', nil, {"words" => ["Drae"] })

    res = @client.get('/anagrams/read.json?propernouns=false')

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    expected = {"anagrams"=>["dear", "dare"]}

    assert_equal(expected["anagrams"].sort, body["anagrams"].sort)
  end

  def test_deleting_word_and_its_anagrams
    #pend

    res = @client.delete('/words/read/anagrams.json')

    assert_equal('204', res.code, "Unexpected response code")
  end

  def test_fetching_if_words_are_anagrams_valid
    #pend
    
    # post more words to data store
    res = @client.post('/anagrams.json', nil, {"words" => ["read", "dear", "dare"] })

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    expected_are_anagrams = "true"

    assert_equal(expected_are_anagrams, body['anagrams'])
  end

  def test_fetching_if_words_are_anagrams_invalid
    #pend
    
    # post more words to data store
    res = @client.post('/anagrams.json', nil, {"words" => ["drae", "dear", "dare"] })

    assert_equal('200', res.code, "Unexpected response code")

    body = JSON.parse(res.body)

    expected_are_anagrams = "false"

    assert_equal(expected_are_anagrams, body['anagrams'])
  end

  def test_bad_format
    #pend # delete me

    # fetch anagrams
    res = @client.get('/anagrams/read.junk')

    assert_equal('400', res.code, "Unexpected response code")
  end

  def test_error_404
    res = @client.get('/anagrams/read.junk')
    assert_equal('400', res.code, "Unexpected response code")
  end
end
