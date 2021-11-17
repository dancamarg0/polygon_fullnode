# Polygon deployment

This is a simplified ansible playbook to install Polygon mainnet/testnet, I decided to publish it because I found the Polygon docs a bit confusing and not up-to-date.

## Initial considerations

1. This is to deploy a Full RPC Node, if you want to deploy a validator you'll need to do some more steps that are not covered here.

2. I deploy heimdall and bor under /polygon directory, if you want to use the default directories simply delete every line that has the variable `polygon_node_home` defined.

3. The playbook is fully idempotent.

## Getting started

This playbook creates the bor and heimdall services under a user's systemd, so you'll only be able to interact with it using the polygon user.

e.g:
```
sudo su - polygon
systemctl --user status bor
```

All variables are set in the group_vars, below are a few steps to take into account before initiating the deploy:

1. Check if we're pulling the latest version of heimdall and bor, you can find the one that will be called in the `heimdall_version` and `bor_version` variables.

2. Replace the value of `heimdall_eth_rpc_url` to an Ethereum RPC node, heimdall needs to query it from time to time.

3. Set your mainnet and testnet nodes IPs under inventory/hosts


## Deploying nodes

Run the following command: `ansible-playbook playbook.yml -i inventory/hosts -K`. It's going to install golang-go first and then start with polygon deployment, if you don't need the golang-go tasks just delete it from playbook.yml

Note: It'll deploy the mainnet and testnet nodes at the same time, you can deploy one at each time by appending `-l mainnet/testnet` to the command above.

## Using tags

I've included some tags on roles/polygon/main.yml to make things easier when we need to update just one service or a set of tasks.

Say you've updated a parameter in the heimdalld.service and you just want to update it in the remote host, you can run: `ansible-playbook playbook.yml -i inventory/hosts -K --tags heimdall_install`

## Post deploy

Now that you have your nodes deployed you'll need to download the network snapshot and unzip it inside the node's data directory.

You can find the snapshots here: https://snapshots.matic.today/

Note: You better download it in a tmux window + nohup or something similar for the mainnet ones, they're big.

### Heimdall mainnet

1. cd /polygon/heimdall/data/
2. tmux new -s heimdall
3. nohup wget -O heimdall_snapshot.tar.gz `SNAPSHOT_LINK.tar.gz` > /dev/null
4. tar -zxvf heimdall_snapshot.tar.gz
5. Ctrl + b then hit `d` to detach.

### Bor mainnet

1. cd /polygon/bor/data/bor/chaindata/
2. tmux new -s bor
3. nohup wget -O bor_snapshot.tar.gz `SNAPSHOT_LINK.tar.gz` > /dev/null  (I generally use the pruned one)
4. tar -zxvf bor_snapshot.tar.gz
5. Ctrl + b then hit `d` to detach.


Follow the same steps for testnet.

IMPORTANT: Start your bor node ONLY when your heimdall has fully synced, if not it won't work.

To check if heimdall has caught up: `curl -s "localhost:26657/status" | jq .result.sync_info.catching_up`. It should show `false` when the node is fully synced.




