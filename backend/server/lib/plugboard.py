from server.lib.database import Database


def reflect_letter(letter: str, switchers: dict[str, str]) -> str:
    """Reflects the letter based on the provided letters configuration."""

    try:
        return switchers.get(letter.lower(), letter.lower())
    except Exception as e:
        print(letter, switchers)
        print(e)
        return "a"


def to_dict(plugs: list[tuple[str, str]]) -> dict:
    plugboard = {}
    for plug in plugs:
        plugboard[plug[0]] = plug[1]
        plugboard[plug[1]] = plug[0]
    return plugboard



async def switch_letter(
    username: str,
    machine: int,
    letter: str,
    conn: Database,
) -> str:
    """Switches the letter with its connected plug if available."""

    plugs = await conn.get_plugboards(username, machine)

    # fill plugboard
    plugboard = to_dict(plugs)

    return reflect_letter(letter, plugboard)
