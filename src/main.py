#!/usr/bin/env python3

# Create HTML5 color roles. <>

from discord import Intents as intents
from discord import Game as game
from discord.ext.commands import Bot as bot
from os import environ as env

GAME = "musical notes 🎶"
ACTIVITY = game(name=GAME)

PREFIX = '!'

TOKEN = env['DISCORD_TOKEN']

INTENTS = intents.default()

bot = bot(command_prefix=PREFIX, intents=INTENTS, activity=ACTIVITY)

@bot.command()
async def ping(ctx):
    await ctx.send('pong')

bot.run(TOKEN)
