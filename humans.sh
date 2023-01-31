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
PEERS="e4234a5fba85b2c3d2ad157b6961ac3d115f4c49@humans-testnet.nodejumper.io:28656,c8be59d2d46a867c57b091a5097e0e6a12a56acf@65.109.23.114:18456,d3e5ebf58cb2132ef6960f17108361eaf700e173@81.0.218.32:26656,c5d5a7b399867350c393f76988e2126012f2e064@75.119.133.212:26656,b5dafa34445cf4fe0e35e0641d172d1c7e72a9b5@109.205.181.30:26656,e1205de09abce3a9281ec39f6353d10a873fb805@89.58.45.204:60556,23d889cc5e39efd933963c719e8c4d1ace137660@38.242.247.207:26656,c8f66a7c2b121fe9a2998acc24a6855d85e1c7bc@213.239.207.175:37656,d80a2e8736f4869ea865df94c18057aa4db9bd8d@142.132.248.253:23156,d1afb2ffe92d35fd55128a6a1ae699ada0399386@137.184.213.23:26656,54b0102d3548e6760e2ec751181f108f85d23c2e@185.215.166.172:26656,aa7706d240317eb7d5a838f31f05f6ce6f3868a0@146.190.98.154:26656,16e6bdd012b108e2a6ebe5fb26a31d0157238850@104.248.240.13:26656,184d6a0b185e263245810f6b8778aad49741c074@213.136.90.117:26656,759b029af65532a443a7893bca2c2cd774ef1ffd@65.108.97.58:2556,e0d59d2c5058552f536f4d21227f6d1050a16d57@65.109.106.91:22656,981e9829afd1679cd9fafc90edc4ff918057e6fe@217.13.223.167:60556,bf5ead4bb8c95a2f839a46679f85832b94a34e08@65.108.9.164:40656,1826d3c4fc4802f9e2d1d0c81d499adaef56b23e@65.109.81.119:33656,198b1c1f136e5d24f33c218a027dd6394dab74ab@135.181.82.28:26656,71861d24b2a481d7129b7ea481c5e07eb7b80417@35.233.250.195:13656,f981952b0d46439b7bc1de9053865f72bcf662df@157.230.240.157:26656,00d6eb30f49fbff22f2d38284a4abbe903c178fa@135.181.178.53:26646,f9b186dffae34134d108e215b8d471c22f9f5b02@195.3.222.188:26656,502be281ff1eff828197182ab3b7894975da7865@95.216.14.72:33656,17f4b40a52cb18293edc4f3c13e33efd09f446d4@65.109.53.60:26656,abe2ca12e23fc56bbc3ed9be92d7a534acc7926a@89.117.57.123:26656,d62cc03a547509ff40d7496c35471c3d640b9f61@34.68.18.235:26656,1f0fddda473602586e6efcb5aeca1b5362ca11eb@188.119.112.164:26656,863418728569feaa78f850db306080d1acf25186@84.46.242.40:27656,f66a056b417f569bfeeb0883687c59078f666a70@81.0.218.102:26656,1f8edd527649a4e8ae99729453f7a6c0319a44ee@65.109.164.110:26656,25adac50f326015fe5434d94ef9ffbcbd2bd062e@51.158.66.152:26656,df698e4ff0e45324d67d312581574be8f3c1c4f1@144.76.27.79:46656,79363f8b7840503b4024d93046066fc8f6c31a7e@89.109.46.167:26656,739c605c870d8ef83a2e168fbaa77d6acfbe0de3@65.21.129.95:26656,2374a6d0b8b34d4d91449fd7931cc02326e7d64e@45.147.199.170:36656,89ac42df14a00e46d332e19ed325d758ca8bae37@38.242.231.113:26656,c2cf4e1d0da9ac1e8be5d5288d0bf8e8052b2d86@65.109.92.148:60856,049d4807acc00a42ed64a57b5f58c1c89d5be9db@65.109.88.180:15656,d55876bc04e363bbe68a7fb344dd65632e310f45@138.201.121.185:26668,70adc2b27a27c69757d7399a21e1e80ee2703d94@65.109.84.215:60856,96622dab2bebab9ff2ae2720feac5866215ad5b7@104.248.254.182:26656,e1fc3fd90808ff158102ef003ef7b6f056d7e27d@185.16.39.19:26656,b49c21582df0f0ff49b56086eb8fbe2f0e7acf7b@194.163.145.180:26656,b42725fda80d7976b4cca94711441337a870e6ff@178.128.144.182:26656,65aad23c6a3d0a8c86e272ceac00ba191497605b@65.108.132.239:45656,ee49dcb485d757b29b1da38487cf130a5df3453a@65.109.24.121:26656,3774885627905fb001fb0d491e490424e0766298@199.175.98.129:26656,5c27e54b2b8a597cbbd1c43905d2c18a67637644@142.132.231.118:56656,783d1695a0ff86c71a75c851653dddc710bee08f@147.139.134.144:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.humans/config/config.toml

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
sed -i.bak -e "s/indexer *=.*/indexer = \"null\"/g" $HOME/.humans/config/config.toml

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
