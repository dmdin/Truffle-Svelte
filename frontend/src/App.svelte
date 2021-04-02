<script>
  import {ethStore, web3, selectedAccount, connected, chainName, nativeCurrency} from 'svelte-web3';
  import {onMount} from 'svelte';
  import Calculator from 'compiledContracts/Calculator.json';

  const provider = 'http://localhost:7545';
  const {abi, networks,} = Calculator;


  onMount(async () => {
    await ethStore.setProvider(provider);
    let accounts = await $web3.eth.getAccounts();
    // const address = accounts[0];
    const networkId = await $web3.eth.net.getId();
    const deployedNetwork = Calculator.networks[networkId];
    const instance = new $web3.eth.Contract(
      Calculator.abi,
      deployedNetwork && deployedNetwork.address,
    );
    console.log(await instance.methods.Add(1, 2).call());
  })

</script>

<main>
  <p>Web3 injected in window: { window.Web3 ? 'yes' : 'no' }</p>

  <p>Web3 version: {$web3.version} </p>

  {#if !$web3.version}
    Please check that web3 as been added in public/index.html with the line:
    <pre>
      &lt;script src="https://cdn.jsdelivr.net/npm/web3@latest/dist/web3.min.js">&lt;/script>
  </pre>
  {/if}

  {#if $connected}
    <p>Connected!</p>
  {:else}
    <p>Not connected!</p>
  {/if}
</main>

<style>
  main {
    text-align: center;
    padding: 1em;
    max-width: 240px;
    margin: 0 auto;
  }

  h1 {
    color: #ff3e00;
    text-transform: uppercase;
    font-size: 4em;
    font-weight: 100;
  }

  @media (min-width: 640px) {
    main {
      max-width: none;
    }
  }
</style>