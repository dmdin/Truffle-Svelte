<script>
  import {time} from './timer';

  export let debtorAddress, borrowerAddress, sum, plus, untilDate, creationDate, status, myAddress;
  export let ExpirationCall = _ => {
  };
  export let TakeCall = _ => {
  };
  export let ReturnCall = _ => {
  };

  const nullAddress = '0x0000000000000000000000000000000000000000';
  let expirationTimeout;
  if (Date.now() < untilDate && status !== "Finished") {
    expirationTimeout = setTimeout(async () => {
      ExpirationCall();
    }, untilDate - Date.now())
  } else if (status != "Finished") {
    console.log(status)
    status = 'Expired';
  }

  function getTimeRemaining(endtime, time) {
    const total = endtime - time;
    const seconds = Math.floor((total / 1000) % 60);
    const minutes = Math.floor((total / 1000 / 60) % 60);
    const hours = Math.floor((total / (1000 * 60 * 60)) % 24);
    const days = Math.floor(total / (1000 * 60 * 60 * 24));

    let res = '';
    if (days > 0) {
      res += `${days}d `
    }
    if (hours > 0) {
      res += `${hours}h `
    }
    if (days === 0) {
      res += `${minutes}m `
    }
    if (seconds > 0 && days === 0 && hours === 0) {
      res += `${seconds}s`
    }
    return res;
  }

  $: timeLeft = getTimeRemaining(untilDate, $time);

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
    <h1 class="eth">{sum} BFT</h1>
    {#if borrowerAddress === myAddress}
      <p>You are a borrower</p>
    {:else}
      <p>from: <a href="/#/{borrowerAddress}">{borrowerAddress}</a></p>
    {/if}
    {#if debtorAddress === myAddress}
      <p>You are a debtor</p>
    {:else if debtorAddress === nullAddress}
      <p>No one took it</p>
    {:else}
      <p>to: <a>{debtorAddress}</a></p>
    {/if}
  </div>
  <div class="right-column">
    <p>Created: {formatDate(creationDate)}</p>
    {#if status !== 'Expired' && status !== 'Finished'}
      <p>Time left: {timeLeft}</p>
    {/if}
    <div class="status">
      <p>Bonus: </p>
      <p style="margin-left: 0;">{plus}BFT</p>
    </div>
    <div class="status">
      <p>Status: </p>
      <p style="color: var({status === 'Expired' ? '--red-color' : '--green-color'}); margin-left: 0;">{status}</p>
    </div>
    <div class="buttons">
      <button class="button" disabled={status !== "Open"} on:click={TakeCall}>Take it</button>
      {#if debtorAddress === myAddress}
        <button class="button" disabled={status !== "Taken" && status !== "Expired"}
                on:click={_ => {ReturnCall(sum + plus); clearTimeout(expirationTimeout)}}>Return
        </button>
      {/if}
    </div>
  </div>
</div>

<style>
  .component {
    background: var(--main-color);
    border-radius: 20px;
    background: #eae8e9;
    box-shadow: 16px 16px 38px #c7c5c6, -16px -16px 38px #ffffff;
    max-width: 600px;
    width: 70%;
    display: flex;
    padding: 30px 60px;
    margin: 40px;
    justify-content: space-between;
  }

  .button {
    margin-top: 10px;
    margin-left: 10px;
    width: 75px;
    border-radius: 20px;
    color: white;
    background: #7699d4;
    border: none;
    cursor: pointer;
  }

  .button:disabled {
    background: #8f8f8f;
  }

  .left-column, .right-column {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    justify-content: center;
    max-width: 300px;
  }

  .status {
    display: flex;
    justify-content: flex-start;
  }

  .right-column {
    justify-content: flex-end;
    width: 230px;
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
    color: #14213d;
    font-size: 18px;
    font-family: var(--main-font);
    margin: 5px 5px 5px 0;
    text-overflow: ellipsis;
    overflow: hidden;
    white-space: nowrap;
    max-width: 250px;
  }

  .eth {
    color: #645986;
    font-size: 4em;
  }

</style>