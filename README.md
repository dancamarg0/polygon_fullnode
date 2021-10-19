# Polygon deployment

This is a simplified ansible playbook to install Polygon mainnet/testnet, I decided to publish it because I found the Polygon docs a bit confusing and not up-to-date.

Note: This is to deploy a Full RPC Node, if you want to deploy a validator you'll need to do some more steps that are not covered here.
Note2: The role is fully idempotent.

This playbook creates the bor and heimdall services under a user's systemd, so you'll only be able to interact with it using the polygon user.

e.g:
```
sudo su - polygon
systemctl --user status bor
```

All variables are set in the group_vars, below are a few steps to take into account before initiating the deploy:

1. Check if we're pulling the latest version of heimdall and bor, you can find the one being used on `heimdall_version` and `bor_version`.

2. Replace the value of `heimdall_eth_rpc_url` to an Ethereum RPC node, heimdall needs to query it from time to time.

3. Set your mainnet and testnet nodes IPs under inventory/hosts


## Deploying nodes

Run the following command: `ansible-playbook playbook.yml -i inventory/hosts`

Note: It'll deploy the mainnet and testnet node at the same time, you can deploy one at each time by specifying `-l mainnet/testnet`

## Using tags

I've included some tags on roles/polygon/main.yml to make things easy when we need to just update one service or a set of tasks.

Say you've updated a parameter in the heimdalld.service and you just want to update it, you can run: `ansible-playbook playbook.yml -i inventory/hosts --tags heimdall_install`

## Post deploy

Now that you have your nodes deployed you'll need to download the network snapshot and unzip it inside the node's data directory.

You can find the snapshots here: https://snapshots.matic.today/

Note: You better download it in a tmux window + nohup or something similar for the mainnet ones, they're big.

### Heimdall mainnet

cd /polygon/heimdall/data/
tmux new -s heimdall
nohup curl https://matic-blockchain-snapshots.s3-accelerate.amazonaws.com/matic-mainnet/heimdall-snapshot-2021-10-19.tar.gz > /dev/null
tar -zxvf heimdall-snapshot-2021-10-19.tar.gz 
Ctrl + b then hit `d` to detach.

### Bor mainnet

cd /polygon/bor/data/bor/chaindata/
tmux new -s bor
nohup curl https://matic-blockchain-snapshots.s3-accelerate.amazonaws.com/matic-mainnet/bor-pruned-snapshot-2021-10-18.tar.gz > /dev/null
tar -zxvf bor-pruned-snapshot-2021-10-18.tar.gz
Ctrl + b then hit `d` to detach.


Follow the same steps for testnet.

IMPORTANT: Start your bor node ONLY when your heimdall has fully synced, if not it won't work.

To check if heimdall has caught up: `curl -s "localhost:26657/status" | jq .result.sync_info.catching_up`. It should show `false` when the node is fully synced.




