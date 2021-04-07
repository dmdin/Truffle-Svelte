<script>
  import {fly} from 'svelte/transition'

  export let coins;
  export let open;
  export let clickCallback;
  let credit = 0, bonus = 0, period = 1000;
  $: enough = credit + bonus < coins;
  let component;
</script>

{#if open}
  <div bind:this={component}
       on:click={event => event.target === component ? open = false : undefined}
       transition:fly={{y: -20}}
       class="background">
    <div class="window">
      <button class="cancel-button" on:click={() => open = false}>
        <svg width=32 height=32>
          <line x1=2 y1=2 x2=14 y2=14></line>
          <line x1=2 y1=14 x2=14 y2=2></line>
        </svg>
      </button>
      <div class="content">
        <h1>New Credit</h1>
        <label>
          Credit:
          <input bind:value={credit} type="number">
        </label>
        <label>
          Bonus:
          <input bind:value={bonus} type="number">
        </label>
        <button class="create-button"
                on:click={_ => {clickCallback(credit, bonus, period); open=false}}
                disabled={!enough}>Create
        </button>
      </div>
    </div>
  </div>
{/if}

<style>
  .background {
    z-index: 1;
    position: fixed;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.7);
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .window {
    width: 40%;
    min-width: 300px;
    max-width: 600px;
    height: 20%;
    background: #eae8e9;
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    margin-bottom: 300px;
  }

  .cancel-button {
    width: 32px;
    height: 32px;
    margin-top: 5px;
    margin-right: 5px;
    background: transparent;
    border-color: transparent;
    cursor: pointer;
  }

  .content {
    width: 100%;
    height: 100%;
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  line {
    stroke: #333333;
  }

  input {
    width: 70px;
    background: transparent;
    border-radius: 30px;
    transition: all 0.7s ease;
    /*color: */
  }

  input:focus {
    outline: none;
    border-color: #333333;
  }

  label {
    text-align: center;
  }

  button {
    margin-top: 10px;
    margin-left: 10px;
    width: 120px;
    padding: 8px;
    border-radius: 20px;
    border: 2px solid transparent;
    color: white;
    background: #7699d4;
    cursor: pointer;
    transition: all 0.7s ease;
  }

  button:hover:enabled {
    background-color: transparent;
    border-color: #7699d4;
    color: #7699d4;
  }

  button:disabled {
    background-color: #999999;
  }

  h1 {
    margin: -5px 0 20px 0;
    padding: 0;
    color: #645986;
    font-size: 2em;
    font-family: var(--main-font);
  }

</style>