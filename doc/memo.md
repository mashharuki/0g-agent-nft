# 試したメモ

## セットアップ

```bash
pnpm i
```

```bash
cp .env.example .env
```

以下4つ分の秘密鍵が必要

```txt
ZG_TESTNET_PRIVATE_KEY=
ZG_AGENT_NFT_CREATOR_PRIVATE_KEY=
ZG_AGENT_NFT_ALICE_PRIVATE_KEY=
ZG_AGENT_NFT_BOB_PRIVATE_KEY=
```

## コンパイル

```bash
pnpm run compile
```

## デプロイ

```bash
pnpm run deploy --network zgTestnet
```

```bash
Deploying TEE Verifier...
deploying "TEEVerifier" (tx: 0x05132f701992f6ee67aced440a856ed27e5c71991a2ac8c1e7101e44fb79ea08)...: deployed at 0xAa363921A48Eac63F802C57658CdEde768B3DAe1 with 483978 gas
TEEVerifier deployed to: 0xAa363921A48Eac63F802C57658CdEde768B3DAe1
deploying "AgentNFTImpl" (tx: 0x74c0f10dad5e0458c34ee0009bd12ae08e660d9c5a12c6bd1c9553fac7df6e05)...: deployed at 0x2B5914De5D5166eBaa423C92BAb8518c85EAA0cb with 3038304 gas
deploying "AgentNFTBeacon" (tx: 0x6d898bcb85f18c613853bca857b5588abcb8a6d053effd0692017620da36a9d5)...: deployed at 0xa05Db9C31B6ffB6aB817D346E99095e1c1c8317D with 252039 gas
deploying "AgentNFT" (tx: 0xd2c35756abcbf6cb450df20600b92cc5a4da54fa6d5c7d221f69b0306c60065c)...: deployed at 0x8DF7e6234f76e8fAC829feF83E7520635359094C with 540828 gas
Deployment and initialization complete
```

## upgrade

```bash
pnpm run upgrade --network zgTestnet
```