from typing import Dict

from server.lib.database import Database


class Plugboard:
    def __init__(self, plugs: Dict[chr, chr]):
        self.plugs = plugs

    def switch_letter(self, letter: chr) -> chr:
        """Switches the letter with its connected plug if available."""
        return self.plugs.get(letter.lower(), letter.lower())


async def switch_letter(username: str, machine: int, letter: str, conn: Database) -> str:
    """Switches the letter with its connected plug if available."""

    plugs = await conn.get_plugboards(username, machine)

    # fill plugboard
    plugboard = {}
    for plug in plugs:
        plugboard[plug[0]] = plug[1]
        plugboard[plug[1]] = plug[0]

    return plugboard.get(letter.lower(), letter.lower())
