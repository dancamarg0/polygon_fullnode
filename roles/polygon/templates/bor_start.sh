#!/usr/bin/env sh

{{ polygon_user_home }}/bin/bor --datadir {{ polygon_node_home }}/bor/data \
  --port 30303 \
  --http --http.addr '0.0.0.0' \
  --http.vhosts '*' \
  --http.corsdomain '*' \
  --http.port 8545 \
  --ipcpath {{ polygon_node_home }}/bor/data/bor.ipc \
  --http.api 'eth,net,web3,txpool,bor' \
  --syncmode 'snap' \
  --networkid '{{ bor_network_id }}' \
  --miner.gasprice '30000000000' \
  --miner.gaslimit '20000000' \
  --miner.gastarget '20000000' \
  --txpool.nolocals \
  --txpool.accountslots 16 \
  --txpool.globalslots 131072 \
  --txpool.accountqueue 64 \
  --txpool.globalqueue 131072 \
  --txpool.lifetime '1h30m0s' \
{% if bor_seeds is defined %}
  --bootnodes "{{ bor_seeds }}" \
{% endif %}
  --maxpeers 200 \
  --metrics \
  --pprof --pprof.port 7071 --pprof.addr '0.0.0.0'