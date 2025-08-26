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

## upgrade

```bash
pnpm run upgrade --network zgTestnet
```