# 💰 Open Credit
[![SvelteIcon](https://img.shields.io/static/v1?label=&message=Svelte&color=white&style=flat&logo=svelte)](https://svelte.dev/) [![Solidity](https://img.shields.io/static/v1?label=&message=Solidity&color=gray&style=flat&logo=Solidity)](https://docs.soliditylang.org/en/v0.8.3/) [![Web3](https://img.shields.io/static/v1?label=&message=Web3&color=%23000000&style=flat)](https://web3js.readthedocs.io/en/v1.3.4/)
[![JavaScript](https://img.shields.io/static/v1?label=&message=JavaScript&color=grey&style=flat&logo=JavaScript)](https://docs.soliditylang.org/en/v0.8.3/)

A credit service written on [Svelte](https://svelte.dev/), [Truffle](https://www.trufflesuite.com/)
 and [Web3](https://web3js.readthedocs.io/en/v1.3.4/) for a blockchain course

### 🚀 Startup
* Create a workspace in [Ganache](https://www.trufflesuite.com/docs/ganache/overview) and select _truffle-config.js_
* Make migrations of contracts from the directory _blockchain_
    ```bash
    $: truffle migrate
    ```
* Install dependencies and run Svelte app via _npm_ or _yarn_ from _frontend_ directory
    ```bash
    $: npm install
    $: npm run dev
    ```
* Open http://localhost:5000 in browser. That's it!
