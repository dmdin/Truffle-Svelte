<center> <h1>Svelte template with Tailwind CSS</h1> </center>

<center>
  <div style="display:flex">
    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Svelte_Logo.svg/199px-Svelte_Logo.svg.png" />
    <img src="https://seeklogo.com/images/T/tailwind-css-logo-5AD4175897-seeklogo.com.png" />
  </div>
</center>

<br>

## Setup

Setting up Tailwind with Svelte is really simple, just install necessary dependencies:

```bash
npm i -D svelte-preprocess tailwindcss postcss postcss-load-config autoprefixer
```

Create your configuration files

```bash
npx tailwindcss init -p
```

Configure **svelte-preprocess** in `rollup.config.js`

```js
// ...
import sveltePreprocess from 'svelte-preprocess';

// ...

export default {
  // ...
  plugins: [
    svelte({
      preprocess: sveltePreprocess({ postcss: true }),
      // ...
    }),
    // ...
  ],
  // ...
};
```

Next, import Tailwind styles into a component and add it to App.svelte

_\*Tailwind styles must be imported into a separate component so that changes can be immediately reflected in the browser._

```svelte
<!-- ./src/Components/Tailwind.svelte -->

<style global>
  @import 'tailwindcss/base';

  @import 'tailwindcss/components';

  @import 'tailwindcss/utilities';
</style>
```

```svelte
<!-- App.svelte -->

<script>
  import Tailwind from './components/Tailwind.svelte';

  export let name;
</script>

<Tailwind />

<main>
  <h1>Hello {name}!</h1>
  <p> Visit the <a href="https://svelte.dev/tutorial">Svelte tutorial</a> to learn how to build Svelte apps.</p>
</main>
```

Finally, configure purge in `tailwind.config.js`:

```js
module.exports = {
  purge: {
    enabled: !process.env.ROLLUP_WATCH,
    mode: 'all',
    content: ['./public/index.html', './src/**/*.svelte'],
  },
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
```

<br>

## Get started with this template

Install the dependencies...

```bash
cd Svelte-Tailwind
npm install
```

...then start [Rollup](https://rollupjs.org):

```bash
npm run dev
```

## Building and running in production mode

```bash
npm run build
```
