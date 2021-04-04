<script>
  import {location} from 'svelte-spa-router';
  import {ethStore, web3, selectedAccount, connected, chainName, nativeCurrency} from 'svelte-web3';
  import {Circle3} from 'svelte-loading-spinners';
  import {onMount} from 'svelte';
  import Debt from './Debt.svelte';
  import Credit from 'compiledContracts/Credit.json';
  import Select from 'svelte-select';

  const provider = 'http://localhost:7545';

  let myAddress, coins, input, instance;
  let accounts = [];
  let showAddress;
  let readonly = true;
  let debts = [];

  async function getDebts(address) {
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

  async function expired(address, index) {

  }

  async function getContract(address) {
    const networkId = await $web3.eth.net.getId();
    const deployedNetwork = Credit.networks[networkId];
    return new $web3.eth.Contract(
      Credit.abi,
      deployedNetwork && deployedNetwork.address, {
        from: address,
        gas: 2000000
      }
    );
  }

  onMount(async () => {
    await ethStore.setProvider(provider);
    accounts = await $web3.eth.getAccounts();
  })

  async function update() {
    coins = await getCoins(showAddress);
    instance = await getContract(myAddress);
    debts = await getDebts(showAddress);
  }

  async function createDebt() {
    let eth = 1;
    // await deposit(myAddress, eth);
    let debt = await instance.methods.createDebt(2, 1000).send({
      from: myAddress, value: await $web3.utils.toWei(eth.toString(), 'ether')
    });
    debts = await getDebts(myAddress);
  }

  async function takeDebt(address, index) {
    await instance.methods.useDebt(address, index).send();
    debts = await getDebts(address);
  }

  async function returnDebt(address, index, value) {
    await instance.methods.returnDebt(index).send();
  }

  let me, other;
  $: myAddress = me && me.value || accounts[0];
  $: showAddress = (other && other.value) || myAddress;
</script>


<main>
  <h1 class="text-gray-600">Open Credits</h1>
  {#if $connected}
    <div class="selects">
      <Select placeholder="Choose your address" items={accounts}
              bind:selectedValue={me} on:select={update}/>
      <Select placeholder="Choose address to show" items={accounts}
              bind:selectedValue={other} on:select={update}/>
    </div>
    {#if me && other}
      <div class="header-wrapper">
        {#if myAddress === showAddress}
          <h2>My coins: {coins}ETH</h2>
          <button class="button" on:click={createDebt}>New Debt</button>
        {:else}
          <h2>Coins: {coins}ETH</h2>
        {/if}

      </div>
      <div class="debts">
        {#each debts as debt, i}
          <!--TODO Update component-->
          <Debt myAddress={myAddress} debt={Object.values(debt)}
                ExpirationCall={_ => expired(showAddress, i)}
                TakeCall={_ => takeDebt(showAddress, i)}
                ReturnCall={(value) => returnDebt(showAddress, i, value)}
          />
        {/each}
      </div>
    {/if}
  {:else}
    <div class="spinner-wrapper">
      <Circle3 size="100" unit="px" duration="2s"/>
    </div>
  {/if}

</main>

<style>
  main {
    display: flex;
    flex-direction: column;
    align-items: center;
    max-width: 1440px;
    width: 100%;
    min-height: calc(100% - 152px);
    margin: 0 auto;
  }

  .selects {
    width: 70%;
    max-width: 300px;
    height: 100px;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    margin-bottom: 20px;
  }

  .header-wrapper {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100%;
  }

  .spinner-wrapper {
    /*width: 100%;*/
    height: 80vh;
    display: flex;
    justify-content: center;
    align-items: center;
  }

  .button {
    margin-top: 10px;
    margin-left: 10px;
    width: 120px;
    padding: 12px;
    border-radius: 20px;
    color: white;
    background: #7699d4;
    border: none;
    cursor: pointer;
  }

  input {
    border: none;
    border-bottom: 1px solid transparent;
    text-overflow: ellipsis;
    white-space: nowrap;
    overflow: hidden;
    transition: border-bottom-color 0.7s ease;
  }

  h1 {
    font-family: var(--main-font);
    font-size: 70px;
    color: #7699d4;
  }

  h2 {
    font-family: var(--main-font);
    margin: 10px 0;
    color: #392f5a;
    font-size: 30px;
    text-overflow: ellipsis;
    overflow: hidden;
    max-width: 500px;
    white-space: nowrap;
  }

  p {
    color: #14213d;
    font-size: 18px;
    font-family: var(--main-font);
    margin: 5px;
    text-overflow: ellipsis;
    overflow: hidden;
    white-space: nowrap;
    max-width: 300px;
  }

</style>