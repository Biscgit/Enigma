import string



class Rotor():
    alphabet = string.ascii_lowercase  
    len_al = len(Rotor.alphabet)
    ord_reducer=ord('a')
    def __init__(self, alphabet: str, start: chr, notch: chr):
        self.mapped_alphabet = str.lower(alphabet)
        self.start = Rotor.get_ord(start)
        self.notch = list(map(Rotor.get_ord, notch)) #[Rotor.get_ord(i) for i in notch ]
    
    def scramble(self, char: chr) -> chr:
        return self.mapped_alphabet[Rotor.get_ord(char) % Rotor.len_al]

    def rescramble(self, char: chr) -> chr:
        return Rotor.alphabet[self.mapped_alphabet.index(char) % Rotor.len_al]

    def scrambler(self, char: chr, back: bool) -> chr:
        return self.rescramble(char) if back else self.scramble(char)

    def rotate(self, notch_on_before: bool) -> bool:
        self.start += 1 if notch_on_before else 0
        self.start %= Rotor.len_al
        return self.start in self.notch

    def add_offset(self, char: chr, back: bool) -> chr:
        value = ((self.mapped_alphabet.index(char) if back else Rotor.get_ord(char)) + self.start) % Rotor.len_al
        return self.mapped_alphabet[value] if back else Rotor.alphabet[value]

    def rotate_offset_scramble(self, char: chr, rotate: bool, back: bool) -> (bool, chr):
        notch = self.rotate(rotate)
        return notch, self.scrambler(self.add_offset(char, back), back)


    @staticmethod
    def get_ord(char: chr) -> int:
        return ord(str.lower(char)) - Rotor.ord_reducer
