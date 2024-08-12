# 👨‍🔬 The Take-Home Task Recap

![take-home-task-preview](/images/take-home-task-preview.png)

## Approach
The general approach was to integrate the new functionality into the existing project as organically as possible, so the new features interact with the existing elements, patterns and approaches. However, some things were intentionally done differently to make the review process easier; for example, all new sources related to the take-home task are stored in the `firefox-ios/TakeHomeTask` folder.

## Task #1: Web Page Summary

### Local LLM models

For manipulating with local LLMs on iOS devices next instruments were tried:

1. [llama.cpp](https://github.com/ggerganov/llama.cpp). The llama.cpp is an open source project designed to run LLM inference of the LLaMA families (and others) on a wide variety of hardware.
2.  [swift-transformers](https://github.com/huggingface/swift-transformers). The `swift-transformers` is a transformers-like API in Swift that focuses on text generation and involving CoreML into the process.

Since no ready-made model was found for working with `swift-transformers` that would be feasible for a mobile devices, the `llama.cpp` was used to accomplish this and the other task. 

Based on observations and the [tables of data](https://github.com/ggerganov/llama.cpp/discussions/406) found in the `llama.cpp` repository, the most optimal balance between memory usage and quality loss is achieved with 4-bit quantization, specifically `q4_k_m`, `q3_km`, or `q4_ks`. These quantization values are currently being used.

To speed up development, the [LLM.swift](https://github.com/eastriverlee/LLM.swift) package was used as a lightweight abstraction layer built on top of `llama.cpp`.

### Getting content

To provide the LLM agent with information about the web page, an external JS script was implementead and used, it collects information from selected HTML elements: p, span, div, h1, h2, h3, etc.

## Task #2: The window.ai API

### LLM models and window API exposing

The approach to selecting and connecting LLM models is the same as in task #1. To interact with the website, the window API was extended by adding an `ai` object using an external JS script. This script passes messages such as `window.ai.createTextSession` and `window.ai.prompt` from the user to the native code and reports back to the user through `console.log`.

## Task #3: Crypto Wallet

### Scope of work

The following scope was agreed upon for the MVP:

1. The user can create a wallet, which will be saved between app sessions.
2. The user can send ETH from the created wallets.

This functionality was implemented and slightly expanded with the ability to create multiple wallets, switch between them, view wallet balances, open the wallet's page on [etherscan.io](https://etherscan.io/) directly in Puma Browser, and more.

### Ethereum Network

Wallets are currently limited to functioning only on the Ethereum Mainnet.

### Communication with the Ethereum network

To enable interaction with the Ethereum network using Swift, the [web3swift](https://github.com/web3swift-team/web3swift) SPM package was integrated.

### Frontend

For the frontend development, the `SwiftUI` framework and its standard elements were used.

### Security

No sensitive information is stored on the user's device. To sign a transaction, the user is prompted to enter the wallet password.

## Building the code
To build the code, please refer to this manual [Firefox for iOS](https://github.com/mozilla-mobile/firefox-ios/blob/main/firefox-ios/README.md).

***


# Firefox for iOS [![codebeat badge](https://codebeat.co/badges/67e58b6d-bc89-4f22-ba8f-7668a9c15c5a)](https://codebeat.co/projects/github-com-mozilla-firefox-ios) [![codecov](https://codecov.io/gh/mozilla-mobile/firefox-ios/branch/main/graph/badge.svg)](https://codecov.io/gh/mozilla-mobile/firefox-ios/branch/main) and Focus iOS

Download [Firefox iOS](https://apps.apple.com/app/firefox-web-browser/id989804926) and [Focus iOS](https://itunes.apple.com/app/id1055677337) on the App Store.

## Building the code
This is a mono repository containing both Firefox and Focus iOS projects. For their related build instructions, please follow the project readme.
- [Firefox for iOS](https://github.com/mozilla-mobile/firefox-ios/blob/main/firefox-ios/README.md)
- [Focus iOS](https://github.com/mozilla-mobile/firefox-ios/blob/main/focus-ios/README.md)

## Getting involved

We encourage you to participate in those open source projects. We love Pull Requests, Issue Reports, Feature Requests or any kind of positive contribution. Please read the [Mozilla Community Participation Guidelines](https://www.mozilla.org/en-US/about/governance/policies/participation/) and our [Contributing guidelines](https://github.com/mozilla-mobile/firefox-ios/blob/main/CONTRIBUTING.md) first. 

- You can [file a new issue](https://github.com/mozilla-mobile/firefox-ios/issues/new/choose) or research [existing bugs](https://github.com/mozilla-mobile/firefox-ios/issues)

If more information is required or you have any questions then we suggest reaching out to us via:
- Chat on Element channel [#fx-ios](https://chat.mozilla.org/#/room/#fx-ios:mozilla.org) and [#focus-ios](https://chat.mozilla.org/#/room/#focus-ios:mozilla.org) for general discussion, or write DMs to specific teammates for questions.
- Open a [Github discussion](https://github.com/mozilla-mobile/firefox-ios/discussions) which can be used for general questions.

Want to contribute on the codebase but don't know where to start? Here is a list of [issues that are contributor friendly](https://github.com/mozilla-mobile/firefox-ios/labels/Contributor%20OK), but make sure to read the [Contributing guidelines](https://github.com/mozilla-mobile/firefox-ios/blob/main/CONTRIBUTING.md) first. 


## License

    This Source Code Form is subject to the terms of the Mozilla Public
    License, v. 2.0. If a copy of the MPL was not distributed with this
    file, You can obtain one at https://mozilla.org/MPL/2.0/
