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
PEERS="e4234a5fba85b2c3d2ad157b6961ac3d115f4c49@humans-testnet.nodejumper.io:28656,fceabdb52e28e110b0c2e695b7295bd14af65f1f@195.201.59.194:26656,198b1c1f136e5d24f33c218a027dd6394dab74ab@135.181.82.28:26656,b49c21582df0f0ff49b56086eb8fbe2f0e7acf7b@194.163.145.180:26656,2374a6d0b8b34d4d91449fd7931cc02326e7d64e@45.147.199.170:36656,2f33b1312afcfffabae9f417bba0d29fe05f609d@65.108.78.101:26656,e1fc3fd90808ff158102ef003ef7b6f056d7e27d@185.16.39.19:26656,737a723cce6c380b14b7e802e61b60999e94842f@135.181.248.204:2556,412888b64c840b879e34bd080dc233603bdd04b6@85.173.113.198:23656,01abf63cc2b799bb53d4d1a8c12f8713737e84ca@157.245.52.27:26656,17f4b40a52cb18293edc4f3c13e33efd09f446d4@65.109.53.60:26656,f88a461adb2db0ffdc9fed8d3caab08a4b327ce7@65.108.231.124:17656,96622dab2bebab9ff2ae2720feac5866215ad5b7@104.248.254.182:26656,c5d5a7b399867350c393f76988e2126012f2e064@75.119.133.212:26656,76c37181ddb27a9917a465d27be248891d85425d@162.248.224.186:26656,3774885627905fb001fb0d491e490424e0766298@199.175.98.129:26656,c2cf4e1d0da9ac1e8be5d5288d0bf8e8052b2d86@65.109.92.148:60856,4853c63022259d8c9f64c73353600249d905d227@212.90.121.121:13656,f981952b0d46439b7bc1de9053865f72bcf662df@157.230.240.157:26656,e0d59d2c5058552f536f4d21227f6d1050a16d57@65.109.106.91:22656,060bd7ca91c16cac478a69374889bf0beeda6ebf@185.173.39.253:26656,295be5393e99c60763c85987fa3f8045af20d828@95.214.53.178:36656,f9b186dffae34134d108e215b8d471c22f9f5b02@195.3.222.188:26656,327d518a106ac960f1d5ea78c228c244f0942562@82.65.197.168:26656,dda6b3e7dcdf4f4312ed3ef6079c8945b8669351@199.175.98.131:26656,69822c67487d4907f162fdd6d42549e1df60c82d@65.21.224.248:26656,f3d94eb33bad79e57af24743cea52cb3fbbbf45c@65.109.70.23:18456,6aab8fbe8d8b8b61a17976f3b154282bec3a2d6c@176.9.22.117:12656,df698e4ff0e45324d67d312581574be8f3c1c4f1@144.76.27.79:46656,70adc2b27a27c69757d7399a21e1e80ee2703d94@65.109.84.215:60856,16e6bdd012b108e2a6ebe5fb26a31d0157238850@104.248.240.13:26656,f0a662bb16f6734f96c287d7012d8b004dc24c67@65.109.92.235:11026,dee3d7cbbb1ac884c008fefab23d53dc9d96b846@185.219.142.182:26656,fde814317053bc105d170c72147b0e40d36fe907@45.147.199.189:36656,33f0ebee09c9420fbc56c61548eab66c5ebdbeb5@91.223.3.144:26756,4b62a984eac3ea70951f3f2a00604730d74e04cd@168.138.197.232:26656,5c27e54b2b8a597cbbd1c43905d2c18a67637644@142.132.231.118:56656,cc3ee41be135382734193f816d7331afa61a3187@45.147.199.172:26656,739c605c870d8ef83a2e168fbaa77d6acfbe0de3@65.21.129.95:26656,184d6a0b185e263245810f6b8778aad49741c074@213.136.90.117:26656,54b0102d3548e6760e2ec751181f108f85d23c2e@185.215.166.172:26656,9d72348318e67750c9bb1e2a12c6a53fae7911eb@75.119.130.88:26656,74fa30a23a7b6204dfc27cd0783c12c0a41cc0bb@5.189.160.248:26656,a19c3bb3872ef2497cb14e283542d4bc2d2254c4@159.223.88.134:656,7f638e38bd726947586830ce1463beff6d823d59@85.239.240.42:26656,a6aa0906e983e164f731968643175e4ac0f15693@199.175.98.130:26656,fd8cbe21a97acbf113b8eb81914f6fc95853a841@194.163.175.142:26656,d62cc03a547509ff40d7496c35471c3d640b9f61@34.68.218.99:26656,42e321189612274151021a1b4bdbb9de15e0844c@217.76.50.222:26656,106449a60c9ad6d24f5058296a13388872856712@188.191.35.202:26656,7b0b40f045e66d83760859f42e8e95ce7ad93409@88.99.164.158:1166"
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
