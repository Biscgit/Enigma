import string



class Rotor():
    alphabet = string.ascii_lowercase  
    def __init__(self, alphabet: str, start: chr, notch: chr):
        self.mapped_alphabet = str.lower(alphabet)
        self.start = str.lower(start)
        self.notch = str.lower(notch)
        self.counter = 0 
        self.ord_reducer=ord('a')
    
    def scramble(self, character: chr) -> chr:
        return self.mapped_alphabet[(ord(str.lower(character)) - self.ord_reducer + self.counter) % len(Rotor.alphabet)]

    def rescramble(self, character: chr) -> chr:
        return Rotor.alphabet[(ord(self.mapped_alphabet.index(character)) - self.ord_reducer - self.counter)% len(Rotor.alphabet)]

    def rotate(self):

        self.counter += 1

