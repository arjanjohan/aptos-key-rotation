# Aptos Account Key Rotation Tutorial

This repository provides a step-by-step guide for **rotating an account's authentication key** on Aptos. Through a simple example, it demonstrates how to upgrade a deployed package after performing key rotation. In a more in-depth example, the guide explains how to rotate the authentication key from and to a **Ledger device**.

The scripts in this repository are based on the guide in the [Aptos documentation on key rotation](https://aptos.dev/en/build/guides/key-rotation) and the [documentation on using Ledger via the Aptos CLI](https://aptos.dev/en/build/cli/trying-things-on-chain/ledger).

## Introduction

Aptos Move accounts have a public address, an authentication key, a public key, and a private key. The public address is permanent, always matching the account's initial authentication key, which is derived from the original private key.

The Aptos account model facilitates the unique ability to rotate an account's private key. Since an account's address is the _initial_ authentication key, the ability to sign for an account can be transferred to another private key without changing its public address.

## Prerequisites

- [Aptos CLI](https://aptos.dev/build/cli). Tested with version 9.6.0. The scripts parse CLI output, so other versions may behave differently.
- Bash shell environment
- Git
- jq (for JSON parsing)

#### For Ledger scripts:
- A Ledger device (Nano S Plus or Nano X recommended)
- Ledger device with basic setup and updated to the latest firmware version. See [Ledger's website](https://www.ledger.com/) for the setup instructions.
- Ledger device with Aptos App installed (version 0.6.9 or higher). Follow [this guide](https://support.ledger.com/article/7326502672285-zd) to set it up.
- Blind signing enabled in the Aptos app settings

## Project Structure

```
.
├── .aptos/             # CLI profiles, including hot wallet private keys (generated)
├── addresses/          # Account and object addresses (generated)
├── build/              # Move build output (generated)
├── keys/               # Hot wallet private and public keys (generated)
├── scripts/basic       # Scripts for the basic key rotation guide
├── scripts/ledger      # Scripts for the Ledger key rotation guide
├── scripts/config.sh   # Network and Ledger configuration
├── sources/            # Move smart contract source files
├── Move.toml           # Move package manifest
```

## Key Rotation Concepts

This tutorial demonstrates several important concepts:

1. **Ownership Follows the Address, Not the Key**: Everything an account owns, including the code object deployed in these guides, is tied to its address. Rotating the key changes who can sign for the address, not the address itself. That is why a package deployed before a rotation can still be upgraded after it.

2. **Proven vs Unproven Key Rotations**: A proven rotation (`account::rotate_authentication_key`) needs signatures from both the current key and the new key, proving ownership of the new key. It updates the `OriginatingAddress` table. An unproven rotation (`account::rotate_authentication_key_call`) only needs the current key and does not update the table. `aptos account rotate-key` performs a proven rotation, and this tutorial only uses proven rotations.

3. **OriginatingAddress Table**: A reverse lookup table that maps authentication keys to account addresses, ensuring a one-to-one mapping.

4. **`set_originating_address` is disabled**: The framework used to let a new account register its own authentication key in the `OriginatingAddress` table via `account::set_originating_address`. That function now always aborts with `ESET_ORIGINATING_ADDRESS_DISABLED` (potential poisoning from account abstraction). A key only enters the table through a proven rotation, which is why the scripts below don't set it.

## Before You Start

- **Run every script from the repository root.** The scripts read and write `./keys` and `./addresses`, and the deploy and upgrade scripts need `Move.toml` in the current directory.
- **Run the scripts of a guide in order.** Each script uses keys, addresses, and CLI profiles created by the scripts before it.
- **Finish one guide before starting the other.** Both guides use the `keys/` and `addresses/` directories. Run a guide's cleanup script before switching.
- **Profiles are stored in the repository.** The CLI saves profiles to `.aptos/config.yaml` in the repository root, with hot wallet private keys in plain text. The file is gitignored. Each cleanup script deletes the profiles its guide created.

## Setup and Demonstration Steps

### Basic Key Rotation Guide

#### 0. Setup Hot Wallet

```bash
bash ./scripts/basic/0_setup_hot_wallet.sh
```

This script:
- Creates the `keys/` and `addresses/` directories
- Generates a hot wallet key with vanity prefix 0xaaa
- Looks up the address (returns the address derived from the key, since the key has no `OriginatingAddress` entry yet)
- Initializes profile `test-profile-1` with the key, which funds the account from the faucet
- Retrieves and displays the authentication key

#### 1. Deploy Object

```bash
bash ./scripts/basic/1_deploy_object.sh
```

This script:
- Deploys the `hello_blockchain` package to a new code object owned by the account
- Saves the object address to `addresses/hello_world_object_address.txt`

#### 2. Rotate Authentication Key

```bash
bash ./scripts/basic/2_rotate_authentication_key.sh
```

This script:
- Generates a second hot wallet key with vanity prefix 0xbbb
- Rotates the authentication key of the first account to the new key and saves it to profile `test-profile-2`
- Shows that both profiles point to the same account address
- Retrieves the new authentication key
- Checks originating addresses for both keys (the original key has none, the new key maps to the first account)

After this script, `test-profile-1` is stale: its key can no longer sign for the account.

#### 3. Upgrade Code Object

```bash
bash ./scripts/basic/3_upgrade_code_object.sh
```

This script:
- Upgrades the deployed package with `test-profile-2`, showing the account kept ownership of the object through the rotation

#### 4. Demonstrate Invalid Rotation (Same Key)

```bash
bash ./scripts/basic/4_rotate_invalid_same_key.sh
```

This script:
- Attempts to rotate to the same key
- Demonstrates the expected error (cannot rotate to the same key). The CLI rejects this before submitting a transaction.

#### 5. Demonstrate Invalid Rotation (Key Already Mapped)

```bash
bash ./scripts/basic/5_rotate_invalid_new_key_already_mapped.sh
```

This script:
- Generates a third hot wallet key with vanity prefix 0xccc
- Initializes profile `test-profile-3` with this key, which creates and funds a new 0xccc account
- Attempts to rotate the 0xccc account to the 0xbbb key, which script 2 already mapped to the 0xaaa account in the OriginatingAddress table
- Demonstrates the expected error (ENEW_AUTH_KEY_ALREADY_MAPPED)

#### 6. Demonstrate Invalid Rotation (Invalid Originating Address)

```bash
bash ./scripts/basic/6_rotate_invalid_invalid_originating_address.sh
```

This script:
- Rotates the 0xaaa account to the 0xccc key and saves it to profile `test-profile-4`. This maps the 0xccc key to the 0xaaa account.
- Attempts to rotate the 0xccc account, whose current key is now mapped to the 0xaaa account
- Demonstrates the expected error (EINVALID_ORIGINATING_ADDRESS)

#### 7. Cleanup

```bash
bash ./scripts/basic/7_cleanup.sh
```

This script:
- Deletes profiles `test-profile-1` through `test-profile-4`
- Removes the `keys/` and `addresses/` directories

### Ledger Key Rotation Guide

#### 0. Setup Hot Wallet

```bash
bash ./scripts/ledger/0_setup_hot_wallet.sh
```

This script:
- Creates the `keys/` and `addresses/` directories
- Generates a hot wallet key with vanity prefix 0xaaa
- Initializes profile `ledger-rotation-hot` with the key, which funds the account from the faucet

#### 1. Deploy Object with Hot Wallet

```bash
bash ./scripts/ledger/1_deploy_object.sh
```

This script:
- Deploys the `hello_blockchain` package to a new code object owned by the account
- Saves the object address to `addresses/deployed_object.txt`

#### 2. Rotate to Ledger

```bash
bash ./scripts/ledger/2_rotate_to_ledger.sh
```

This script:
- Rotates the account's authentication key to a Ledger key and saves it to profile `ledger-rotation-ledger`
- Uses the derivation index set by `DERIVATION_INDEX` in `scripts/config.sh` (default 1000; a high index is best practice)
- Asks you to approve the rotation proof challenge signature on the Ledger
- Verifies that both profiles point to the same account with different public keys

After this script, `ledger-rotation-hot` is stale: its key can no longer sign for the account.

#### 3. Upgrade Object with Ledger

```bash
bash ./scripts/ledger/3_upgrade_object_with_ledger.sh
```

This script:
- Upgrades the deployed package with `ledger-rotation-ledger`, asking you to approve the transaction on the Ledger
- Shows the account kept ownership of the object through the rotation to the Ledger

#### 4. Rotate to Hot Wallet

```bash
bash ./scripts/ledger/4_rotate_to_hot_wallet.sh
```

This script:
- Generates a new hot wallet key with vanity prefix 0xbbb
- Rotates the account's authentication key from the Ledger to the new key and saves it to profile `ledger-rotation-temp-hot`
- Asks you to approve the rotation proof challenge signature and then the transaction on the Ledger
- Renames the now stale `ledger-rotation-ledger` profile to `ledger-rotation-ledger-stale`

Rotating to a temporary hot wallet is useful for transactions too large for the Ledger to sign.

#### 5. Upgrade Object with Hot Wallet

```bash
bash ./scripts/ledger/5_upgrade_object_with_hot_wallet.sh
```

This script:
- Upgrades the deployed package with `ledger-rotation-temp-hot`
- Shows how to handle larger transactions that might not fit on Ledger

#### 6. Cleanup

```bash
bash ./scripts/ledger/6_cleanup.sh
```

This script:
- Deletes all `ledger-rotation-*` profiles
- Removes the `keys/` and `addresses/` directories


## Key Rotation Security Considerations

- **One-to-One Mapping**: Best practice is to maintain a one-to-one mapping between authentication keys and account addresses.
- **Originating Address**: `set_originating_address` is disabled, so a new account's key can't be registered in the OriginatingAddress table up front. It only gets an entry after a proven rotation.
- **Private Keys**: Keep your private keys secure and never share them.
- **Proven Rotations**: Use proven key rotations to ensure proper updates to the OriginatingAddress table.

## Network

This tutorial is configured to work with Aptos devnet by default. To use a different network, modify the network settings in the `scripts/config.sh` file:

```bash
# Network configuration
NETWORK="devnet"
FULLNODE_URL="https://fullnode.devnet.aptoslabs.com"
```

*Note: When you change these values to work with other networks like testnet, the CLI won't faucet new accounts directly. This means the scripts might fail without some modifications.*

Devnet is reset periodically, which wipes all accounts and deployed packages. If a reset happens partway through a guide, run its cleanup script and start again from script 0.

## Troubleshooting

If you encounter any issues:

1. Ensure Aptos CLI is properly installed and in your PATH
2. Make sure you run the scripts from the repository root
3. Verify you have sufficient test tokens for transactions
4. To start fresh, run the guide's cleanup script. Deleting `keys/` and `addresses/` by hand leaves the CLI profiles behind in `.aptos/config.yaml`.

## Understanding Error Cases

The scripts intentionally demonstrate several error cases:
- Attempting to rotate to the same key (script 4)
- Attempting to rotate to a key already mapped in the OriginatingAddress table (script 5)
- Attempting to rotate with an invalid originating address (script 6)

These error cases help illustrate the security mechanisms in the Aptos account model.
