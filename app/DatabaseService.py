KEY_WORD_LENGTHS = "countOfWordLengths"
KEY_MAX_GROUP_SIZE = "maxGroupSize"

class DatabaseService:

    def __init__(self, db0, db1):
        self.db0 = db0
        self.db1 = db1

    def updateDB1GroupSizes(self, key, groupSizeDelta):
        if self.db0.exists(key):
            newGroupSize = self.db0.scard(key)
        else:
            newGroupSize = 0

        # where the key group is currently sitting
        currentGroupSize = newGroupSize - groupSizeDelta

        # if group changed in size, remove key from previous group. vice versa
        self.db1.srem(self.groupKeyWord(currentGroupSize), key)

        # update to new group bucket. Don't place in bucket if group count is 0
        if newGroupSize != 0:
            self.db1.sadd(self.groupKeyWord(newGroupSize), key)

        # compare to max group size and update new max if new group is larger
        if self.db1.exists(KEY_MAX_GROUP_SIZE):
            currentMaxGroupSize = int( list(self.db1.smembers(KEY_MAX_GROUP_SIZE) )[0] )
        else:
            currentMaxGroupSize = 0
            self.db1.sadd(KEY_MAX_GROUP_SIZE, currentMaxGroupSize)

        if newGroupSize > currentMaxGroupSize:
            temp = self.db1.spop(KEY_MAX_GROUP_SIZE)
            self.db1.sadd(KEY_MAX_GROUP_SIZE, newGroupSize)
        else:
            # check that max group still has entries; if none, then update to next
            maxGroupSetSize = int(self.db1.scard(self.groupKeyWord(currentMaxGroupSize)))
            if maxGroupSetSize == 0:
                for groupSize in range(currentMaxGroupSize, -1, -1):
                    if int(self.db1.scard(self.groupKeyWord(groupSize))) > 0:
                        temp = self.db1.spop(KEY_MAX_GROUP_SIZE)
                        self.db1.sadd(KEY_MAX_GROUP_SIZE, groupSize)
                        break

    @staticmethod
    def groupKeyWord(count):
        return "groupSize" + str(count)