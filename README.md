Coffeebot agent
===============
Coffeebot agent for Ubiquiti Networks mFi mPower products https://www.ubnt.com/mfi/mpower/. Tested only on mPower mini.

See coffeebot-server/README.md for overall instructions.

Tuo install the agent run:

```
./install.sh <mpower-ip-or-dns-address> <coffeebot-server-address> <username> <pwd>
```

for example:

```
./install.sh coffeebot-agent.example.com http://coffeebot-server.example.com ubnt ubnt
```

Agent debugging
----------------
Connect to mPower device (default username/password is ubnt/ubnt):

```
ssh -oKexAlgorithms=+diffie-hellman-group1-sha1 ubnt@<mpower-ip-or-dns-address>
```

Client ID is stored in file  `/etc/persistent/bin/coffee-agent.id`. Coffeebot-agent is `/etc/persistent/bin/coffee-agent.sh`.
