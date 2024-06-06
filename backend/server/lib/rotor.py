import string
from functools import partial
from typing import Tuple


class Rotor:
    alphabet = string.ascii_lowercase
    len_al = len(alphabet)

    def __init__(self, alphabet: str, start: chr, notch: str):
        """
        Initialize the Rotor with a given alphabet, starting position, and notch positions.

        :param alphabet: The scrambled alphabet used by the rotor.
        :param start: The starting character of the rotor.
        :param notch: The notch positions where the next rotor will be rotated.
        """
        self.mapped_alphabet = alphabet.lower()
        get_ord_false = partial(self.get_ord, back=False)
        self.start = get_ord_false(start) - 7
        self.notch = list(map(get_ord_false, notch))

    def scramble(self, char: chr) -> chr:
        """
        Scramble a character using the rotor's mapping.

        :param char: The input character to be scrambled.
        :return: The scrambled character.
        """
        return self.mapped_alphabet[self.get_ord(char, False) % Rotor.len_al]

    def rescramble(self, char: chr) -> chr:
        """
        Rescramble a character using the rotor's inverse mapping.

        :param char: The input character to be rescrambled.
        :return: The rescrambled character.
        """
        return Rotor.alphabet[self.get_ord(char, True) % Rotor.len_al]

    def scrambler(self, char: chr, back: bool) -> chr:
        """
        Scramble or rescramble a character based on the direction.

        :param char: The input character to be processed.
        :param back: Direction flag; True for rescrambling, False for scrambling.
        :return: The processed character.
        """
        return self.rescramble(char) if back else self.scramble(char)

    def rotate(self, notch_on_before: bool) -> bool:
        """
        Rotate the rotor and check if the notch is triggered.

        :param notch_on_before: Flag to determine if the rotor should rotate.
        :return: True if the notch is at the current position, False otherwise.
        """
        self.start += 1 if notch_on_before else 0
        self.start %= Rotor.len_al
        return self.start in self.notch

    def add_offset(self, char: chr, back: bool) -> chr:
        """
        Add or subtract the rotor's offset to the character.

        :param char: The input character.
        :param back: Direction flag; True for adding offset, False for subtracting.
        :return: The character with offset applied.
        """
        value = (
            self.get_ord(char, back) + (self.start if back else -self.start)
        ) % Rotor.len_al
        return self.mapped_alphabet[value] if back else Rotor.alphabet[value]

    def rotate_offset_scramble(
        self, char: chr, rotate: bool, back: bool
    ) -> Tuple[bool, chr]:
        """
        Rotate the rotor, apply the offset, and scramble the character.

        :param char: The input character.
        :param rotate: Flag to determine if the rotor should rotate.
        :param back: Direction flag; True for rescrambling, False for scrambling.
        :return: Tuple containing the notch status and the processed character.
        """
        notch = self.rotate(rotate)
        return notch, self.scrambler(self.add_offset(char, back), back)

    def get_ord(self, char: chr, back: bool) -> int:
        """
        Get the ordinal index of a character.

        :param char: The input character.
        :param back: Direction flag; True for using mapped alphabet, False for using regular alphabet.
        :return: The index of the character in the appropriate alphabet.
        """
        return (
            self.mapped_alphabet.index(char.lower())
            if back
            else Rotor.alphabet.index(char.lower())
        )
