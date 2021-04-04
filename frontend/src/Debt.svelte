<script>
  export let debt;
  export let myAddress;
  const nullAddress = '0x0000000000000000000000000000000000000000';
  let [debtorAddress, borrowerAddress, sum, untilDate, creationDate, expired] = debt;
  untilDate = new Date(untilDate * 1000);
  creationDate = new Date(creationDate * 1000);

  if (Date.now() < untilDate) {
    setTimeout(() => expired = true, untilDate - Date.now())
  } else {
    expired = true;
  }

  function formatDate(date) {
    let d = date;
    d = [
      '0' + d.getHours(),
      '0' + d.getMinutes(),
      '0' + d.getDate(),
      '0' + (d.getMonth() + 1),
      '' + d.getFullYear()
    ].map(component => component.slice(-2));
    return d.slice(0, 2).join(':') + ' / ' + d.slice(2).join('.');
  }
</script>

<div class="component">
  <div class="left-column">
    <h1 class="eth">{sum} ETH</h1>
    {#if debtorAddress === myAddress}
      <p>You are a borrower</p>
    {:else}
      <button on:click={_=>{}}>Debtor: {debtorAddress}</button>
    {/if}
    {#if borrowerAddress === myAddress}
      <p>You are a debtor</p>
    {:else if borrowerAddress === nullAddress}
      <p>No one took it</p>
    {:else}
      <button>Borrower: {borrowerAddress}</button>
    {/if}
  </div>
  <div class="right-column">
    <p>{formatDate(untilDate)}</p>
    <p>{formatDate(creationDate)}</p>
    {#if !expired}
      <p>Expired: <i class="green">No</i></p>
    {:else}
      <p>Expired: <i class="red">Yes</i></p>
    {/if}
  </div>
</div>

<style>
  .component {
    background: var(--main-color);
    border-radius: 20px;
    background: #eae8e9;
    box-shadow: 16px 16px 38px #c7c5c6, -16px -16px 38px #ffffff;
    max-width: 500px;
    width: 70%;
    display: flex;
    padding: 30px;
    margin: 20px;
    justify-content: space-evenly;
  }

  .left-column, .right-column{
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    justify-content: center;
  }

  h1 {
    margin: 0;
    font-family: var(--main-font);
    /*margin-left: ;*/
  }

  .right-column p {
    margin: 5px 15px;
  }

  p {
    color: #03191E;
    font-size: 18px;
    font-family: var(--main-font);
    margin: 5px;
  }

  .eth {
    color: #645986;
    font-size: 4em;
  }
</style>