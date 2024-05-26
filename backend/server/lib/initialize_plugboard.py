from typing import Dict


class Plugboard:
    def __init__(self, plugs: Dict[str, str]):
        self.plugs = plugs

    def switch_letter(self, letter: str) -> str:
        """Switches the letter with its connected plug if available."""
        return self.plugs.get(letter, letter)

    def key_press(self, key: str) -> str:
        """Routes the key press through the plugboard."""
        return self.switch_letter(key.lower()).upper()
