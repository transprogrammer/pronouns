#!/usr/bin/env python3

# Create HTML5 color roles. <>

from lib.client import Client
import discord
from os import environ as env

GAME = "growing up"

TOKEN = env['DISCORD_TOKEN']

intents = discord.Intents.default()

activity = discord.Game(name=GAME)

client = Client(intents=intents, activity=activity)

client.run(TOKEN)
