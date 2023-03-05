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
PEERS="e4234a5fba85b2c3d2ad157b6961ac3d115f4c49@humans-testnet.nodejumper.io:28656,6ddd50f50db250a07be3eee49ba292a506711fed@38.242.152.19:26656,3efab6a417a5c83f48655585009132094f525d30@5.182.33.180:26656,d62cc03a547509ff40d7496c35471c3d640b9f61@37.120.171.213:26656,e8c875d2462e66ed5ee2671df4ba310cc9f8a4bf@95.214.55.62:60556,06eccc575007f82dc30ee61fc8e3cda7ddd16d79@164.92.80.193:26656,ab268f6c587a44a318d5f255c81801e03e210956@91.107.145.37:26656,b49c21582df0f0ff49b56086eb8fbe2f0e7acf7b@194.163.145.180:26656,1e84e30c54c43d287b38bb3aaa0395ed9d6eb635@75.119.151.74:26656,45e5978d0bbbf817acc1c4d83a11a194f9ffdaad@5.78.45.105:26656,8cbb758e204172698bd61731c2ac52e1bca20180@161.97.99.251:36656,731949d27444c1a92c24b11c37534d0d2a45422e@95.217.40.230:36656,2f33b1312afcfffabae9f417bba0d29fe05f609d@65.108.78.101:26656,5c27e54b2b8a597cbbd1c43905d2c18a67637644@142.132.231.118:56656,c2cf4e1d0da9ac1e8be5d5288d0bf8e8052b2d86@65.109.92.148:60856,17f4b40a52cb18293edc4f3c13e33efd09f446d4@65.109.53.60:26656,049d4807acc00a42ed64a57b5f58c1c89d5be9db@65.109.88.180:15656,f9b186dffae34134d108e215b8d471c22f9f5b02@195.3.222.188:26656,0a78ef1c78672e8873b859fc912a4f3d6d541781@38.242.247.193:26656,739c605c870d8ef83a2e168fbaa77d6acfbe0de3@65.21.129.95:26656,1f0fddda473602586e6efcb5aeca1b5362ca11eb@188.119.112.164:26656,70adc2b27a27c69757d7399a21e1e80ee2703d94@65.109.84.215:60856,852eb15330eeeaf7c38d6ab300c9768f7ee12039@157.245.195.54:26656,3d15c5a429ef3b749a07fc626f7975153bfdc452@146.19.24.52:17656,e0d59d2c5058552f536f4d21227f6d1050a16d57@65.109.106.91:22656,cc3ee41be135382734193f816d7331afa61a3187@65.109.173.219:26656,f3d94eb33bad79e57af24743cea52cb3fbbbf45c@65.109.70.23:18456,76c37181ddb27a9917a465d27be248891d85425d@162.248.224.186:26656,8cac314e299bed1b150bd19abfe77f7edb56c1e5@81.0.220.132:26656,63b22dc6595a4ad3e84826777b23a371c2bc4d6d@84.54.23.195:26656,00d6eb30f49fbff22f2d38284a4abbe903c178fa@135.181.178.53:26646,3f13ad6e8795479b051d147a5049bf4bd0a63817@65.109.87.88:22656,caf7bd21c0443f46c5e9b3218005e1a2af07931c@195.3.222.189:28656,8d6ac9f9509f1617cd9bac9c4758f7ed5f062cda@144.91.88.213:31656,dbe5b8151100b4a2498655c9393ed3842df1b1ce@95.217.233.76:26656,8b843a7190dd8c921abd8a44b94688997bc425b8@135.181.221.185:16656,bbba7a25ba9bbb4b074ed076da36b90a4009b62c@65.108.248.63:26656,f981952b0d46439b7bc1de9053865f72bcf662df@157.230.240.157:26656,a1ac4162991707eeeaff954870c5438b628ba76d@178.62.37.28:26656,ee49dcb485d757b29b1da38487cf130a5df3453a@65.109.24.121:26656,1e2fddf561299cdd634b8b5ad93bb2df0791673d@176.37.119.156:26656,f88a461adb2db0ffdc9fed8d3caab08a4b327ce7@65.108.231.124:17656,0b7a5eae0f7a6990b741d22794fa4ac9489c0e02@34.28.12.9:26656,42e321189612274151021a1b4bdbb9de15e0844c@217.76.50.222:26656"
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

curl https://snapshots-testnet.nodejumper.io/humans-testnet/testnet-1_2023-02-17.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.humans

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
