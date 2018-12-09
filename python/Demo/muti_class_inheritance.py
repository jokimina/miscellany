# coding: utf-8
class First(object):
    def __init__(self):
        print "first"

    def foo(self):
        print "first foo."

class Second(First):
    def __init__(self):
        print "second"

    def foo(self):
        print "second foo."

class Third(First):
    def __init__(self):
        print "third"

    def foo(self):
        print "third foo."

class Fourth(Second, Third):
    def __init__(self):
        super(Fourth, self).__init__()
        print "that's it"



if __name__ == '__main__':
    """
    second
    that's it
    second foo.
    """
    f = Fourth()
    f.foo()
    print f.__class__
    print Fourth.__mro__
