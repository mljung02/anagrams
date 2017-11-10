# Anagrams API- Ibotta Candidate Project 
by Justin Kruse

---

This anagram API is my submission for the Ibotta Candidate Project. Requirements can be found in the [Ibotta folder](/ibotta).

## Contents
1. [Run locally](#run-locally)
2. [Add words](#add-words)
3. [Delete a single word](#delete-a-single-word)
4. [Delete a word and its anagrams](#delete-a-word-and-its-anagrams)
5. [Delete all words from the data store](#delete-all-words-from-the-data-store)
6. [Get anagrams for a word](#get-anagrams-for-a-word)
7. [Get anagram sets containing at least x words](#get-anagram-sets-containing-at-least-x-words)
8. [Check if a set of words are anagrams of eachother](#check-if-a-set-of-words-are-anagrams-of-eachother)
9. [Get stats on words contained in the data store](#get-stats-on-words-contained-in-the-data-store)
10. [Design](#design)
11. [Testing](#testing)
12. [Benchmarking](#benchmarking)
13. [Other features that could be useful](#other-features-that-could-be-useful)

---

## Run locally
**OS**
Linux/Ubuntu

###### Installs
**Redis for data store**
- Install [Redis](https://redis.io/topics/quickstart)

**Python: Flask and Redis**
- Install [Python](https://packaging.python.org/guides/installing-using-linux-tools/). Version 2.7
- Install [Flask](http://flask.pocoo.org/docs/0.12/installation/)
- Install [Redis](https://pypi.python.org/pypi/redis) for Python

**Ruby**
- Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/)

###### Run
**Start**
1. Start Redis server: ```redis-server --daemonize yes```
2. Clone project to desired directory
3. Terminal 1: Run App
From project directory:
- ```cd app```
- ```FLASK_APP=anagrams.py flask run```
4. Terminal 2: API calls, Test, Benchmark
From project directory:
- ```cd test```
- API calls: see [Ibotta README.md](https://github.com/tehKruser/anagramsAPI/blob/master/ibotta/README.md) for instructions on curl or irb
- Test: ```ruby anagram_test.rb```
- Benchmark: ```ruby anagram_benchmark.rb```

Optional:
To populate words from dictinoary in data store:
- In project directory /script: ```ruby anagram_dbload``` (approx. 3 minutes)

**Stop**
1. Redis shutdown: ```redis-cli shutdown```
2. App shutdown, Terminal 2: Ctrl+c

---

## Add words
Add words to the data store:
`POST /words.json`

**Input**

Name  | Type         | Description
----- | ------------ | -------------
words | string array | words as strings to be posted to data store are in an array

Example: ```curl -i -X POST -d '{ "words": ["read", "dear", "dare"] }' http://127.0.0.1:5000/words.json```

**Response**
```
HTTP/1.0 201 CREATED
```

## Delete a single word
Removes a word from the data store:

`DELETE /words/:word.json`

Example: ```curl -i -X DELETE http://localhost:5000/words/read.json```

**Response**
```
HTTP/1.0 204 NO CONTENT
```

## Delete a word and its anagrams
Removes a word and its anagrams from the data store:

`DELETE /words/:word/anagrams.json`

Example: ```curl -i -X DELETE http://localhost:5000/words/read/anagrams.json```

**Response**
```
HTTP/1.0 204 NO CONTENT
```

## Delete all words from the data store
Removes all words from the data store:

`DELETE /words.json`

Example: ```curl -i -X DELETE http://localhost:5000/words.json```

**Response**
```
HTTP/1.0 204 NO CONTENT
```

## Get anagrams for a word
Get anagrams for a word:

`GET /anagrams/:word.json`

**Parameters**

Name        | Type          | Description
----------- | ------------- | -------------
limit       | int           | maximum number of anagrams to return
propernouns | boolean       | true (default): allow propernouns<br>false: do not return propernouns

Example: ```curl -i -X GET http://localhost:5000/anagrams/read.json```

**Response**
```
HTTP/1.0 200 OK

{
  "anagrams": [
    "Drae",
    "dear",
    "dare"
  ]
}
```

## Get anagram sets containing at least x words
Get all sets of anagrams with at least :x words:

`GET /sets/anagrams/size/:x.json`

:x can be a value > 1 or "max" to return the anagram set(s) that contains the most words

Example: ```curl -i -X GET http://localhost:5000/sets/anagrams/size/3.json```

**Response**
```
HTTP/1.0 200 OK

{
  "sets": [
    {
      "anagrams": [
        [
          "act",
          "tac",
          "cat"
        ]
      ],
      "size": 3
    },
    {
      "anagrams": [
        [
          "read",
          "Drae",
          "dear",
          "dare"
        ]
      ],
      "size": 4
    }
  ]
}
```

## Check if a set of words are anagrams of eachother

Post a set of words and receive a reponse if all words are anagrams of eachother:

`POST /anagrams.json`

**Input**

Name  | Type         | Description
----- | ------------ | -------------
words | string array | words as strings to check if all are anagrams of eachother

Example: ```curl -i -X POST -d '{ "words": ["dork", "dear", "dare"] }' http://127.0.0.1:5000/anagrams.json```

**Response**
```
HTTP/1.0 200 OK

{
  "anagrams": "false"
}
```

## Get stats on words contained in the data store
Get stats for words in data store:

`GET /words/stats.json`

Example: ```curl -i -X GET http://localhost:5000/words/stats.json```

**Response**
```
HTTP/1.0 200 OK

{
  "count": 9,
  "length": {
    "average": 3.56,
    "max": 5,
    "median": 4.0,
    "min": 2
  }
}
```


## Design

**Data Store Design with Redis**

Below is a visualization of adding a word to the data store.

![DB Visualization](https://tehkruser.github.io/anagramsAPI/img/db_visualization.JPG)

There are 3 main aspects:
1. Track words that are anagrams of one another in the db0 set (database 0)
2. Track data about how many words have :x length in the db1 list - for stat tracking
3. Track which anagram keys have :x group size - for retreiving sets of anagrams of size >= :x

**Why Redis?**

I chose Redis because it is a fast, in-memory key-value data store that comes with a set of versatile in-memory data structures. 

The key-value aspect is important because I decided on using a key-value method for storing words in anagram groups. 

The versatile data structures is an ideal solution to:
- store the anagrams in sets with no duplicates,
- and track information about word count and lengths in a list.

Also, did I say it was fast? Since I was only using sets and lists, the add/delete operations were of time complexity O(1), or O(N) for N items being added or deleted. The number of words in the data store had no effect.

Admittedly, I had not used Redis before, but I had already started researching it prior to the "coffee interview", as it was listed in the Ibotta Platform Engineer job description as a scalable technology. After spending time in tutorials and understanding Redis usage, I decided it would be a good opportunity to showcase my ability to learn and implement a new technology.

**Python and Flask**

I was already familiar with developing API's in Python and Google App Engine using webapp2, so I started researching if Redis could be used in the GAE standard environment. The answer was 'no', but it could be used with the flexible environment. This bit of research turned me on to Flask, which looked easy and fun, so I decided to use it as the API framework and develop on my local machine.

## Testing

**Edge cases**

- When returning 1 anagram: Redis has a "srandmembers" method that will return the number of members passed in as an argurment. Initially, it was my intent to use this, but I ran into the issue of possibly getting back the :word supplied in the URL, or if proper nounds were being filterd, then a proper noun could be the 1 random member returned. 

The solution was to 1) return all members, 2) filter :word and proper noun accordingly 3) use Python's random sample method on a list object to get the number of anagrams requested in the parameters.


- Running stats after various scenarios: I decided to do a few unit tests on 'GET stats' because I wanted to test that stats were being updated properly after the following actions:
  - adding a word
  - deleting 1 word
  - deleting 1 word and all of its anagrams
 
 These three actions required the stats to be updated in a different way.
 
**Results**

```
$ ruby anagram_test.rb
Loaded suite anagram_test
Started
......................

Finished in 0.3829484 seconds.
-----------------------------------------------------------------------------------------------
22 tests, 59 assertions, 0 failures, 0 errors, 0 pendings, 0 omissions, 0 notifications
100% passed
-----------------------------------------------------------------------------------------------
57.45 tests/s, 154.07 assertions/s
```


## Benchmarking

When implementing the Redis database, I was taking note of the time complexities that Redis documentation listed for various data structures and functions. Sets and lists had methods that were all O(1), whereas sorted sets had O(log N) to remove and add.  So, I designed my data base and functions around O(1) methods. 

The plots under 'Results' show the amount of time it took to make N calls to the API. I used a log scale transformation to help visualize that the data for GET POST and DELETE of a word is linear. This shows that making N calls to the API is O(N) time complexity. For getting stats, however, the time was fairly consistent, regardless of how big N got. This is due to the stats being tracked in a list in db1. After loading the english language dictionary into the database, then at most, the list was only 24 in length. So at worst, this API call required iterating through a list of 24 elements.

Every operation within the API was essentially C_1 * O(1), where C_1 is some constant time to execute the lines of code. Every call to the API from the benchmark module was C_2 * O(1), where C_2 is the time to receive the data back. This means that total time is (C_1 + C_2) * O(1) = C * O(1). If we are making N calls, then our time complexity is O(N). The number of words in the data store had no effect on the time complexity.

You may notice that adding words is much faster than deleting or getting, but that is because 100 words at a time were sent in a POST, thus dividing the C_2 time by 100, but increasing C_1 by some factor close to 100.  The reduced time makes sense because C_1 is server side operations and will be much faster than bundling and transferring information across the network. 

**Results**
```
$ ruby anagram_benchmark.rb
<<<<<POST Words Benchmarking>>>>>
N       Time
10      0.019427999999606982
20      0.028018999997584615
40      0.051315999997314066
80      0.08272199999919394
100     0.10010099999635713
200     0.22532499999942956
400     0.38907599999947706
800     0.7779430000009597
1000    0.997443000000203
2000    1.994024999999965
4000    4.052944999995816
8000    7.888904999999795
<<<<<GET Anagrams Benchmarking>>>>>
N       Time
10      0.031253999994078185
20      0.05486599999858299
40      0.10991199999989476
80      0.2310719999950379
100     0.3034320000006119
200     0.622269999999844
400     1.185779999999795
800     2.2658269999956246
1000    2.824016999999003
2000    5.942531000000599
4000    11.424890999995114
8000    22.588236000003235
<<<<<DELETE Words Benchmarking>>>>>
N       Time
10      0.03092599999945378
20      0.06424400000105379
40      0.12788300000102026
80      0.23576000000321073
100     0.3433320000040112
200     0.6159849999967264
400     1.1956399999980931
800     2.4315480000004754
1000    2.985372000002826
2000    6.019474000000628
4000    11.977814999998373
8000    23.8830850000013
<<<<<GET Stats Benchmarking>>>>>
N       Time
10      0.006074000004446134
20      0.004381999999168329
40      0.004435000002558809
80      0.005133999999088701
100     0.004345000001194421
200     0.00718800000322517
400     0.0054059999965829775
800     0.0076349999944795854
1000    0.0053039999984321184
2000    0.0047410000042873435
4000    0.00518000000010943
8000    0.0071959999986574985
```

POST words

![POST words](https://tehkruser.github.io/anagramsAPI/img/bm_post_words.JPG)

GET anagrams

![GET words](https://tehkruser.github.io/anagramsAPI/img/bm_get_words.JPG)

DELETE words

![DELETE words](https://tehkruser.github.io/anagramsAPI/img/bm_delete_words.JPG)

GET stats

![GET words](https://tehkruser.github.io/anagramsAPI/img/bm_get_stats.JPG)


## Other features that could be useful

One feature that I thought would be fun to implement is to get stats on anagrams. For example, how many words have only :x anagrams? For this to happen, I think another list would work where each index  represents how many words only have an anagram count equal to index.
