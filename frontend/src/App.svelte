<script>
  import {ethStore, web3, selectedAccount, connected, chainName, nativeCurrency} from 'svelte-web3';
  import Router from 'svelte-spa-router';
  import Page from './Page.svelte';

  const routes = {
    '/*': Page,
  };
</script>

<Router {routes}/>


<footer>
  <p>Web3 injected in window:
    <i class:green={window.Web3} class:red={!window.Web3}>{ window.Web3 ? 'yes' : 'no' }</i>
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
    --red-color: #F02D3A;
    --green-color: #58BC82;
    background: var(--main-color);
  }
  .green {
    color: var(--green-color);
  }
  .red {
    color: var(--red-color);
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