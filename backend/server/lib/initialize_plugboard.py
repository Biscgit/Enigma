from typing import Dict


class Plugboard:
    def __init__(self, plugs: Dict[chr, chr]):
        self.plugs = plugs

    def switch_letter(self, letter: chr) -> chr:
        """Switches the letter with its connected plug if available."""
        return self.plugs.get(letter.lower(), letter.lower())
