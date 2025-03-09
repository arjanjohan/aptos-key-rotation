# Aptos Account Key Rotation Tutorial

This repository provides a step-by-step guide for **rotating an account's authentication key** on Aptos. Through a simple example, it demonstrates how to upgrade a deployed package after performing key rotation. In a more in-depth example, the guide explains how to rotate the authentication key from and to a **Ledger device**.

The scripts in this repository are based on the guide in the [Aptos documentation on key rotation](https://aptos.dev/en/build/guides/key-rotation) and the [documentation on using Ledger via the Aptos CLI](https://aptos.dev/en/build/cli/trying-things-on-chain/ledger).

## Introduction

Aptos Move accounts have a public address, an authentication key, a public key, and a private key. The public address is permanent, always matching the account's initial authentication key, which is derived from the original private key.

The Aptos account model facilitates the unique ability to rotate an account's private key. Since an account's address is the _initial_ authentication key, the ability to sign for an account can be transferred to another private key without changing its public address.

## Prerequisites

- [Aptos CLI](https://aptos.dev/cli-tools/aptos-cli-tool/install-aptos-cli)
- Bash shell environment
- Git
- jq (for JSON parsing)

#### For Ledger scripts:
- A Ledger device (Nano S Plus or Nano X recommended)
- Ledger device with basic setup and updated to the latest firmware version. See [Ledger's website](https://www.ledger.com/) for the setup instructions.
- Ledger device with Aptos App installed (version 0.6.9 or higher). Follow [this guide](https://support.ledger.com/article/7326502672285-zd) to set it up.

## Project Structure

```
.
├── addresses/          # Generated keys and addresses (will be created)
├── keys/               # Generated keys and addresses (will be created)
├── scripts/basic       # Scripts for the basic key rotation guide
├── scripts/ledger      # Scripts for the Ledger key rotation guide
├── scripts/config.sh   # Network and Ledger configuration
├── sources/            # Move smart contract source files
├── Move.toml           # Move package manifest
```

## Key Rotation Concepts

This tutorial demonstrates several important concepts:

1. **Proven vs Unproven Key Rotations**: The tutorial shows proven key rotations using `account::rotate_authentication_key`, which updates the `OriginatingAddress` table.

2. **OriginatingAddress Table**: A reverse lookup table that maps authentication keys to account addresses, ensuring a one-to-one mapping.

3. **Best Practices**: Setting originating addresses for new accounts and handling key rotations properly.

## Setup and Demonstration Steps

### Basic Key Rotation Guide

#### 0. Setup Hot Wallet

```bash
bash ./scripts/basic/0_setup_hot_wallet.sh
```

This script:
- Creates necessary directories
- Generates a hot wallet key with vanity prefix 0xaaa
- Looks up the address (which fails as expected since the account doesn't exist yet)
- Initializes Aptos CLI with the generated key
- Retrieves and displays the authentication key

#### 1. Set Originating Address

```bash
bash ./scripts/basic/1_set_originating_address.sh
```

This script:
- Checks the current originating address (empty at first)
- Sets the originating address using `account::set_originating_address`
- Verifies the updated originating address

#### 2. Deploy Object

```bash
bash ./scripts/basic/2_deploy_object.sh
```

This script:
- Deploys an object using the initialized account

#### 3. Rotate Authentication Key

```bash
bash ./scripts/basic/3_rotate_authentical_key.sh
```

This script:
- Generates a second hot wallet key with vanity prefix 0xbbb
- Rotates the authentication key of the first account to the new key
- Shows profile configurations before and after rotation
- Retrieves the new authentication key
- Checks originating addresses for both keys

#### 4. Upgrade Code Object

```bash
bash ./scripts/basic/4_upgrade_code_object.sh
```

This script:
- Upgrades the previously deployed code object using the rotated key

#### 5. Demonstrate Invalid Rotation (Same Key)

```bash
bash ./scripts/basic/5_rotate_invalid_same_key.sh
```

This script:
- Attempts to rotate to the same key
- Demonstrates the expected error (cannot rotate to the same key)

#### 6. Demonstrate Invalid Rotation (Key Already Mapped)

```bash
bash ./scripts/basic/6_rotate_invalid_new_key_already_mapper.sh
```

This script:
- Generates a third hot wallet key with vanity prefix 0xccc
- Initializes a new profile with this key
- Attempts to rotate to a key that's already mapped in the OriginatingAddress table
- Demonstrates the expected error (ENEW_AUTH_KEY_ALREADY_MAPPED)

#### 7. Demonstrate Invalid Rotation (Invalid Originating Address)

```bash
bash ./scripts/basic/7_rotate_invalid_invalid_originating_address.sh
```

This script:
- Rotates the authentication key of the first account to use the third key
- Attempts to rotate the third account's key
- Demonstrates the expected error (EINVALID_ORIGINATING_ADDRESS)

#### 8. Cleanup

```bash
bash ./scripts/basic/8_cleanup.sh
```

This script:
- Deletes all test profiles
- Removes generated directories and files
- Cleans up the environment

### Ledger Key Rotation Guide

#### 0. Setup Hot Wallet

```bash
bash ./scripts/ledger/0_setup_hot_wallet.sh
```

This script:
- Creates a hot wallet with a vanity address
- Initializes the Aptos CLI with this hot wallet
- Prepares the account for key rotation

#### 1. Set Originating Address

```bash
bash ./scripts/ledger/1_set_originating_address.sh
```

This script:
- Sets the originating address for the hot wallet
- Prepares the account for proper key rotation

#### 2. Deploy Object with Hot Wallet

```bash
bash ./scripts/ledger/2_deploy_object.sh
```

This script:
- Deploys a Move package using the hot wallet
- Establishes the hot wallet as the package owner

#### 3. Rotate to Ledger

```bash
bash ./scripts/ledger/3_rotate_to_ledger.sh
```

This script:
- Rotates the hot wallet's authentication key to use your Ledger
- Uses a high derivation index (1000+) as a best practice
- Demonstrates the key rotation process with hardware wallet
- Creates a new profile for the Ledger-secured account

#### 4. Upgrade Object with Ledger

```bash
bash ./scripts/ledger/4_upgrade_object_with_ledger.sh
```

This script:
- Upgrades the previously deployed package using the Ledger
- Verifies that the Ledger-secured account maintains the same permissions
- Demonstrates that key rotation preserves account capabilities

#### 5. Rotate to Hot Wallet

```bash
bash ./scripts/ledger/5_rotate_to_hot_wallet.sh
```

This script:
- Rotates the authentication key back to a new hot wallet
- Useful for operations that exceed Ledger memory limitations
- Creates a temporary hot wallet profile

#### 6. Upgrade Object with Hot Wallet

```bash
bash ./scripts/ledger/6_upgrade_object_with_hot_wallet.sh
```

This script:
- Upgrades the package using the temporary hot wallet
- Demonstrates that the rotated hot wallet maintains the same permissions
- Shows how to handle larger transactions that might not fit on Ledger

#### 7. Cleanup

```bash
bash ./scripts/ledger/7_cleanup.sh
```

This script:
- Deletes all test profiles
- Removes generated directories and files
- Cleans up the environment


## Key Rotation Security Considerations

- **One-to-One Mapping**: Best practice is to maintain a one-to-one mapping between authentication keys and account addresses.
- **Originating Address**: Always set the originating address after generating a new account.
- **Private Keys**: Keep your private keys secure and never share them.
- **Proven Rotations**: Use proven key rotations to ensure proper updates to the OriginatingAddress table.

## Network

This tutorial is configured to work with Aptos devnet by default. To use a different network, modify the network settings in the `scripts/../config.sh` file:

```bash
# Network configuration
NETWORK="devnet"
FULLNODE_URL="https://fullnode.devnet.aptoslabs.com"
```

*Note: When you change these values to work with other networks like testnet, the CLI won't faucet new accounts directly. This means the scripts might fail without some modifications.*

## Troubleshooting

If you encounter any issues:

1. Ensure Aptos CLI is properly installed and in your PATH
2. Check that all scripts have execute permissions (`chmod +x scripts/*.sh`)
3. Verify you have sufficient test tokens for transactions
4. Clear the `keys/` and `addresses/` directories and start fresh if needed

## Understanding Error Cases

The scripts intentionally demonstrate several error cases:
- Attempting to rotate to the same key (script 5)
- Attempting to rotate to a key already mapped in the OriginatingAddress table (script 6)
- Attempting to rotate with an invalid originating address (script 7)

These error cases help illustrate the security mechanisms in the Aptos account model.

## License

This project is open-source and available under the MIT License.
