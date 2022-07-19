#!/usr/bin/env python3

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# REQ: Creates HTML5 color roles. <skr>

from discord import Intents as intents
from discord import Game as game
from discord import Color as color
from discord.ext.commands import Bot as bot
from os import environ as env
from webcolors import CSS3_NAMES_TO_HEX as names

PREFIX = '!'

COLOR = color.default()
INTENTS = intents.default()

ACTIVITY = game(name="musical notes 🎶")

TOKEN = env['DISCORD_TOKEN']

BOT = bot(command_prefix=PREFIX, intents=INTENTS, activity=ACTIVITY)

@BOT.command(aliases='rock')
@BOT.has_permissions(manage_roles=True)
async def sing(ctx):
    guild = ctx.guild
    
    for name, hex in names.items: 
        await ctx.send(f'{name}:{hex}')

    await guild.create_role(name=name,
                            permissions=discord.Permissions.membership(),
                            color=COLOR)
                            hoist=True)

    await ctx.send(f'Role `{name}` has been created')

BOT.run(TOKEN)
