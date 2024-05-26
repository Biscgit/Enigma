class Plugboard:
    def __init__(self, plugs):
        self.plugs = plugs

    def substitute_letter(self, letter):
        for plug_pair in self.plugs:
            if letter in plug_pair:
                return plug_pair[1] if letter == plug_pair[0] else plug_pair[0]
        return letter

    @staticmethod
    def initialize_plugboard(plugboard_response):
        plugs = []
        for plug_pair in plugboard_response["plugboard"]:
            plugs.append((plug_pair[0], plug_pair[1]))
        return Plugboard(plugs)
