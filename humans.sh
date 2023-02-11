#!/bin/bash

while true
do

# Logo

echo -e '\e[40m\e[91m'
echo -e '  ____                  _                    '
echo -e ' / ___|_ __ _   _ _ __ | |_ ___  _ __        '
echo -e '| |   |  __| | | |  _ \| __/ _ \|  _ \       '
echo -e '| |___| |  | |_| | |_) | || (_) | | | |      '
echo -e ' \____|_|   \__  |  __/ \__\___/|_| |_|      '
echo -e '            |___/|_|                         '
echo -e '    _                 _                      '
echo -e '   / \   ___ __ _  __| | ___ _ __ ___  _   _ '
echo -e '  / _ \ / __/ _  |/ _  |/ _ \  _   _ \| | | |'
echo -e ' / ___ \ (_| (_| | (_| |  __/ | | | | | |_| |'
echo -e '/_/   \_\___\__ _|\__ _|\___|_| |_| |_|\__  |'
echo -e '                                       |___/ '
echo -e '\e[0m'

sleep 2

# Menu

PS3='Select an action: '
options=(
"Install"
"Create Wallet"
"Create Validator"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install")
echo "============================================================"
echo "Install start"
echo "============================================================"

# set vars
if [ ! $NODENAME ]; then
	read -p "Enter node name: " NODENAME
	echo 'export NODENAME='$NODENAME >> $HOME/.bash_profile
fi
if [ ! $WALLET ]; then
	echo "export WALLET=wallet" >> $HOME/.bash_profile
fi
echo "export HUMANS_CHAIN_ID=testnet-1" >> $HOME/.bash_profile
source $HOME/.bash_profile

# update
sudo apt update && sudo apt upgrade -y

# packages
sudo apt install curl build-essential git wget jq make gcc tmux chrony -y

# install go
if ! [ -x "$(command -v go)" ]; then
  ver="1.18.2"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

# download binary
cd $HOME
rm -rf lava
git clone https://github.com/humansdotai/humans
cd humans
git checkout v1.0.0
go build -o humansd cmd/humansd/main.go
sudo cp humansd /usr/local/bin/humansd

# config
humansd config chain-id $HUMANS_CHAIN_ID
humansd config keyring-backend test

# init
humansd init $NODENAME --chain-id $HUMANS_CHAIN_ID

# download genesis and addrbook
curl -s https://rpc-testnet.humans.zone/genesis | jq -r .result.genesis > genesis.json
cp genesis.json $HOME/.humans/config/genesis.json

# set minimum gas price
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.025uheart\"/" $HOME/.humans/config/app.toml

# set peers and seeds
SEEDS=""
PEERS="e4234a5fba85b2c3d2ad157b6961ac3d115f4c49@humans-testnet.nodejumper.io:28656,fceabdb52e28e110b0c2e695b7295bd14af65f1f@195.201.59.194:26656,d5daa4f7089019fb845f18b0dd9ac9b47c3afe93@23.88.71.247:30656,d5e444638a236c6cf3e09167224f48b2f77a6611@185.198.27.109:2556,0894ef6d99c39bccb6c568b77dcdfe0807522ece@95.165.89.222:24137,0c12992ed524efc83b9c8c03b4f82d5e07595b2a@194.233.80.63:26656,e1fc3fd90808ff158102ef003ef7b6f056d7e27d@185.16.39.19:26656,198b1c1f136e5d24f33c218a027dd6394dab74ab@135.181.82.28:26656,636648f03fdda72d7caec67fcbf5e20a8a53d590@109.123.244.178:26656,01abf63cc2b799bb53d4d1a8c12f8713737e84ca@157.245.52.27:26656,17f4b40a52cb18293edc4f3c13e33efd09f446d4@65.109.53.60:26656,f981952b0d46439b7bc1de9053865f72bcf662df@157.230.240.157:26656,327d518a106ac960f1d5ea78c228c244f0942562@82.65.197.168:26656,2f33b1312afcfffabae9f417bba0d29fe05f609d@65.108.78.101:26656,412888b64c840b879e34bd080dc233603bdd04b6@85.173.113.198:23656,049d4807acc00a42ed64a57b5f58c1c89d5be9db@65.109.88.180:15656,c2cf4e1d0da9ac1e8be5d5288d0bf8e8052b2d86@65.109.92.148:60856,4853c63022259d8c9f64c73353600249d905d227@212.90.121.121:13656,4b62a984eac3ea70951f3f2a00604730d74e04cd@168.138.197.232:26656,e0d59d2c5058552f536f4d21227f6d1050a16d57@65.109.106.91:22656,9726b7ba17ee87006055a9b7a45293bfd7b7f0fc@45.136.40.16:26656,76c37181ddb27a9917a465d27be248891d85425d@162.248.224.186:26656,f9b186dffae34134d108e215b8d471c22f9f5b02@195.3.222.188:26656,dc4d6e5bc6a6a75f177d4d59ad584f9fbd3eb009@104.248.232.113:13656,d62cc03a547509ff40d7496c35471c3d640b9f61@34.68.218.99:26656,69822c67487d4907f162fdd6d42549e1df60c82d@65.21.224.248:26656,54b0102d3548e6760e2ec751181f108f85d23c2e@185.215.166.172:26656,6aab8fbe8d8b8b61a17976f3b154282bec3a2d6c@176.9.22.117:12656,df698e4ff0e45324d67d312581574be8f3c1c4f1@144.76.27.79:46656,70adc2b27a27c69757d7399a21e1e80ee2703d94@65.109.84.215:60856,16e6bdd012b108e2a6ebe5fb26a31d0157238850@104.248.240.13:26656,f0a662bb16f6734f96c287d7012d8b004dc24c67@65.109.92.235:11026,96622dab2bebab9ff2ae2720feac5866215ad5b7@104.248.254.182:26656,28cee93eee4b0b800b362f8bba5a3edd25ff1030@195.201.83.166:48656,33f0ebee09c9420fbc56c61548eab66c5ebdbeb5@91.223.3.144:26756,c5d5a7b399867350c393f76988e2126012f2e064@75.119.133.212:26656,96fc064917274a80d43985a5c3440254dcae5dc9@65.108.134.208:36656,aec858a71cd3a57f7da8bcd5e80eca17d269af21@159.223.212.84:17656,739c605c870d8ef83a2e168fbaa77d6acfbe0de3@65.21.129.95:26656,184d6a0b185e263245810f6b8778aad49741c074@213.136.90.117:26656,5c27e54b2b8a597cbbd1c43905d2c18a67637644@142.132.231.118:56656,9d72348318e67750c9bb1e2a12c6a53fae7911eb@75.119.130.88:26656,a4f9fd8d76dd3fb4fc72b174be1e3bd6590a4d53@45.147.176.14:26656,54ca3e14e71fefb83ada327bcab7eed603907af3@65.109.165.99:26656,1e32e98f500f95ffde43236ec84153a051621130@15.235.80.84:26656,c692c561c78549f4cfa8be220913189d5e35da30@164.90.221.176:26656,958509db695a02e9cf514bb99793051bea11af45@65.109.88.251:11026,23a72466c5b0633f19a6fb959cd66368b348d014@170.64.178.175:27656,3774885627905fb001fb0d491e490424e0766298@199.175.98.129:26656,2685f8e77fec93c99a55f2adb13835a50124d04e@135.181.18.112:55686,e42caa91e00da31258aa1b7b9a9e5d64062d6739@167.172.72.136:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.humans/config/config.toml

# disable indexing
indexer="null"
sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/.humans/config/config.toml

# config pruning
pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.humans/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.humans/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.humans/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.humans/config/app.toml
sed -i "s/snapshot-interval *=.*/snapshot-interval = 0/g" $HOME/.humans/config/app.toml

# enable prometheus
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.humans/config/config.toml

# create service
sudo tee /etc/systemd/system/humansd.service > /dev/null << EOF
[Unit]
Description=Humans Network Node
After=network-online.target
[Service]
User=$USER
ExecStart=$(which humansd) start
Restart=on-failure
RestartSec=10
LimitNOFILE=10000
[Install]
WantedBy=multi-user.target
EOF

humansd tendermint unsafe-reset-all --home $HOME/.humans

# start service
sudo systemctl daemon-reload
sudo systemctl enable humansd
sudo systemctl start humansd

break
;;

"Create Wallet")
humansd keys add $WALLET
echo "============================================================"
echo "Save address and mnemonic"
echo "============================================================"
HUMANS_WALLET_ADDRESS=$(humansd keys show $WALLET -a)
HUMANS_VALOPER_ADDRESS=$(humansd keys show $WALLET --bech val -a)
echo 'export HUMANS_WALLET_ADDRESS='${HUMANS_WALLET_ADDRESS} >> $HOME/.bash_profile
echo 'export HUMANS_VALOPER_ADDRESS='${HUMANS_VALOPER_ADDRESS} >> $HOME/.bash_profile
source $HOME/.bash_profile

break
;;

"Create Validator")
humansd tx staking create-validator \
  --amount 10000000uheart \
  --from wallet \
  --commission-max-change-rate "0.1" \
  --commission-max-rate "0.2" \
  --commission-rate "0.1" \
  --min-self-delegation "1" \
  --pubkey  $(humansd tendermint show-validator) \
  --moniker $NODENAME \
  --chain-id testnet-1 \
  --fees=5000uheart \
  -y
  
break
;;

"Exit")
exit
;;
*) echo "invalid option $REPLY";;
esac
done
done
