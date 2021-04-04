<script>
  import {ethStore, web3, selectedAccount, connected, chainName, nativeCurrency} from 'svelte-web3';
  import {onMount} from 'svelte';
  import Credit from 'compiledContracts/Credit.json';
  import {Circle3} from 'svelte-loading-spinners';
  import Debt from './Debt.svelte';

  const provider = 'http://localhost:7545';

  let accounts, myAddress, coins, input, instance;
  let showAddress;
  let readonly = true;
  let debts = [];

  async function getDebts(address) {
    // console.log(await instance.methods.createDebt(4, 2).send());
    let list = [];
    let length = await instance.methods.getLength(address).call();
    for (let i = 0; i < length; i++) {
      list.push(instance.methods.getDebts(address, i).call());
    }
    return await Promise.all(list);
  }

  async function getCoins(address) {
    let coins = await $web3.eth.getBalance(address);
    coins = await $web3.utils.fromWei(coins);
    coins = Math.round(coins * 100) / 100;
    return coins;
  }

  async function getContract() {
    const networkId = await $web3.eth.net.getId();
    const deployedNetwork = Credit.networks[networkId];
    return new $web3.eth.Contract(
      Credit.abi,
      deployedNetwork && deployedNetwork.address, {
        from: accounts[0],
        gas: 2000000
      }
    );
  }

  onMount(async () => {
    await ethStore.setProvider(provider);
    accounts = await $web3.eth.getAccounts();
    myAddress = accounts[0];
    showAddress = myAddress;
    instance = await getContract();
    coins = await getCoins(showAddress);
    debts = await getDebts(showAddress);
    console.log(await getDebts(showAddress));
    console.log(await instance.methods.getLength(showAddress).call());
  })

  async function createDebt() {
    let debt = await instance.methods.createDebt(14, 5000).send();
    debts = await getDebts(myAddress);
  }
</script>

<main>
  {#if $connected}

    <h1 class="text-gray-600">Open Credits</h1>
    <label>
      My address:
      <input type="text" bind:value={myAddress} bind:this={input} {readonly}
             on:blur={_ => readonly = true}
             on:click={_ => readonly = false}
      >
    </label>
    <h2>My coins: {coins}ETH</h2>
    <button on:click={createDebt}>New Debt</button>
    <h2>My debts:</h2>
    <div class="debts">
      {#each debts as debt}
        <Debt {myAddress} debt={Object.values(debt)}/>
      {/each}
    </div>
  {:else}
    <div class="spinner-wrapper">
      <Circle3 size="100" unit="px" duration="2s"/>
    </div>
  {/if}
</main>

<footer>
  <p>Web3 injected in window: <i class:green={window.Web3} class:red={!window.Web3}>{ window.Web3 ? 'yes' : 'no' }</i>
  </p>
  {#if $connected}
    <p class="green">Blockchain is connected!</p>
  {:else}
    <p>Blockchain is not connected!</p>
  {/if}
  <p>Web3 version: {$web3.version} </p>
  {#if !$web3.version}
    Please check that web3 as been added in public/index.html with the line:
    <pre>
      &lt;script src="https://cdn.jsdelivr.net/npm/web3@latest/dist/web3.min.js">&lt;/script>
    </pre>
  {/if}
</footer>


<style>
  :root {
    --main-color: #eae8e9;
    --main-font: 'Barlow', sans-serif;
    background: var(--main-color);

  }

  main {
    text-align: center;
    max-width: 1440px;
    width: 100%;
    min-height: 1000px;
    margin: 0 auto;
  }

  .spinner-wrapper {
    width: 100%;
    height: 80%;
    display: flex;
    justify-content: center;
    align-items: center;
  }

  input {
    border: none;
    border-bottom: 1px solid transparent;
    text-overflow: ellipsis;
    white-space: nowrap;
    overflow: hidden;
    transition: border-bottom-color 0.7s ease;
  }

  input:focus {
    outline: none;
    border-bottom-color: #666666;
  }

  .green {
    color: #58BC82;
  }

  .red {
    color: #F02D3A;
  }

  .debts {
    display: flex;
    flex-direction: column;
    align-items: center;
    margin-bottom: 60px;
  }

  footer {
    margin: 0;
    padding: 0;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    border: 1px solid gray;
    /*position: absolute;*/
    bottom: 0;
    width: calc(100% - 2px);
    height: 150px;
    font-family: var(--main-font);
  }

  p {
    margin: 5px 0;
    padding: 0;
  }

</style>