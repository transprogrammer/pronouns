#!/usr/bin/env python3

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# REQ: Creates HTML5 color roles. <skr>

from discord import Intents as intents
from discord import Game as game
from discord.ext.commands import Bot as bot
from os import environ as env

GAME = "musical notes 🎶"
ACTIVITY = game(name=GAME)

PREFIX = '!'

TOKEN = env['DISCORD_TOKEN']

INTENTS = intents.default()

BOT = bot(command_prefix=PREFIX, intents=INTENTS, activity=ACTIVITY)

@BOT.command()
async def sing(ctx):
    await ctx.send('song')

BOT.run(TOKEN)
