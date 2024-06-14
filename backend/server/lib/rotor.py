import string
from functools import partial
from typing import Tuple


class Rotor:
    alphabet = string.ascii_lowercase
    len_al = len(alphabet)

    def __init__(
        self,
        alphabet: str,
        rotor_position: chr,
        letter_shift: str,
        id: int,
        machine_id: int,
        place: int,
        number: int,
    ):
        """
        Initialize the Rotor with a given alphabet, rotor_positioning position, and letter_shift positions.

        :param alphabet: The scrambled alphabet used by the rotor.
        :param rotor_position: The rotor_positioning character of the rotor.
        :param letter_shift: The letter_shift positions where the next rotor will be rotated.
        """
        self.scramble_alphabet = alphabet.lower()
        get_ord_false = partial(self.get_ord, back=False)
        self.rotor_position = get_ord_false(rotor_position) - 7
        self.letter_shift = list(map(get_ord_false, letter_shift))
        self.id = id
        self.machine_id = machine_id
        self.place = place
        self.number = number

    def scramble(self, char: chr) -> chr:
        """
        Scramble a character using the rotor's mapping.

        :param char: The input character to be scrambled.
        :return: The scrambled character.
        """
        return self.scramble_alphabet[self.get_ord(char, False) % Rotor.len_al]

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

    def rotate(self, letter_shift_on_before: bool) -> bool:
        """
        Rotate the rotor and check if the letter_shift is triggered.

        :param letter_shift_on_before: Flag to determine if the rotor should rotate.
        :return: True if the letter_shift is at the current position, False otherwise.
        """
        self.rotor_position += 1 if letter_shift_on_before else 0
        self.rotor_position %= Rotor.len_al
        return self.rotor_position in self.letter_shift

    def add_offset(self, char: chr, back: bool) -> chr:
        """
        Add or subtract the rotor's offset to the character.

        :param char: The input character.
        :param back: Direction flag; True for adding offset, False for subtracting.
        :return: The character with offset applied.
        """
        value = (
            self.get_ord(char, back)
            + (self.rotor_position if back else -self.rotor_position)
        ) % Rotor.len_al
        return self.scramble_alphabet[value] if back else Rotor.alphabet[value]

    def rotate_offset_scramble(
        self, char: chr, rotate: bool, back: bool
    ) -> Tuple[bool, chr]:
        """
        Rotate the rotor, apply the offset, and scramble the character.

        :param char: The input character.
        :param rotate: Flag to determine if the rotor should rotate.
        :param back: Direction flag; True for rescrambling, False for scrambling.
        :return: Tuple containing the letter_shift status and the processed character.
        """
        letter_shift = self.rotate(rotate)
        return letter_shift, self.scrambler(self.add_offset(char, back), back)

    def get_ord(self, char: chr, back: bool) -> int:
        """
        Get the ordinal index of a character.

        :param char: The input character.
        :param back: Direction flag; True for using mapped alphabet, False for using regular alphabet.
        :return: The index of the character in the appropriate alphabet.
        """
        return (
            self.scramble_alphabet.index(char.lower())
            if back
            else Rotor.alphabet.index(char.lower())
        )

    def get_str_notch(self) -> str:
        """
        Construct a string representing notches using the current letter shifts.

        :return: A string where each character represents the notch position in the Rotor's alphabet.
        """
        return "".join([Rotor.alphabet[notch] for notch in self.letter_shift])
