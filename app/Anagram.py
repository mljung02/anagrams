from flask import request
from flask import jsonify

class Anagram:
    BAD_REQUEST_MESSAGE = '400 Bad Request : only JSON data supported at this time\n'
    UNPROCESSABLE_MESSAGE = '422 Unprocessable Entity: Missing "words" entity\n'

    def __init__(self, data_format, request):
        self.data_format = data_format
        self.request = request
        self.code = None
        self.error_message = None
        self.response = {'anagrams': "true"}

    def validate(self):
        if not self.isValidFormat():
            self.code = 400
            self.error_message = self.BAD_REQUEST_MESSAGE
        if not self.isValidEntity():
            self.code = 422
            self.error_message = self.UNPROCESSABLE_MESSAGE


    def isValidFormat(self):
        return self.data_format == 'json'

    def isValidEntity(self):
        try:
            self.getWords()
        except:
            return False
        return True

    def getWords(self):
        return self.__formattedRequest()['words']

    def __formattedRequest(self):
        if self.data_format == 'json':
            try:
                return request.get_json(force=True)
            except:
                return None
        else:
            return None

    def formattedResponse(self):
        if self.data_format == 'json':
            return jsonify(self.response)
        else:
            return None

    def checkIfContainsWords(self, anagrams):
        for word in self.getWords():
            if word not in anagrams:
                self.response = {'anagrams': "false"}
                break
