# bot_rts_lua

This is a client side cheat I made for garry's mod, it uses flask to allow other alt accounts to communicate with each other. 
However I lost the python files for the flask server and I lost the code to automatically load up gmod clients up.

To load up multiple garry's mod accounts you need the accounts with garry's mod ownership, you cannot do family share because only 
one family shared account can play at a time.

The flash python code just relays botN.setBotData and botN.getBotData which uses post to send data to the server. You cannot use your local ip address because
garry's mod disables post from being send to your local ip. So you will need to portforward your ip for it to work.

The lua file includes a ui system based on the game Company of Heroes 2, I didn't get to complete the ui system so its kinda of terrible but it also includes a* path finding,
I didnt't get to fully complete it but the first iteration of the path finding system is based on many a* path finding algorisms and generates nodes in run time to the target
destination, this worked but sometimes it would get stuck and not generate or it would take a few seconds to generate. This wasnt verey good for a rts style bot system because 
you wouldn't want to wait a few seconds for your bot to move plus the http.post lag it would mean it would take 3 - 5 seconds for your bot to move.

I went to a better approach of this and made my own node graph system but I didn't get to finish it. The basic nodes work but I was planning to do macro nodes and other types of 
nodes.

