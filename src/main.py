#!/usr/bin/env python3

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# REQ: Creates HTML5 color roles. <skr>

from discord import Intents
from discord import Game
from discord import Colour
from discord.ext.commands import Bot
from os import environ
from webcolors import CSS3_NAMES_TO_HEX

PREFIX = '!'

HOIST = True
INTENTS = Intents.default()

ACTIVITY = Game(name="musical notes 🎶")

TOKEN = environ['DISCORD_TOKEN']

BOT = Bot(command_prefix=PREFIX, intents=INTENTS, activity=ACTIVITY)

@BOT.command(aliases=['rock','punk'])
async def sing(context):
    for name, hex in CSS3_NAMES_TO_HEX.items(): 
        hex_color = Colour.from_str(hex)

        await context.send(f'{name}:{hex}')
        await context.guild.create_role(name=name, color=hex_color, hoist=HOIST)


BOT.run(TOKEN)
