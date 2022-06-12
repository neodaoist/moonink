const fs = require('fs');
const path = require('path');
//const serve = require(path.join(__dirname, '..', '..', 'lib/hot-chain-svg', 'serve.js'));
const serve = require('../../lib/hot-chain-svg/src/serve');
const boot = require('../../lib/hot-chain-svg/src/boot');
const call = require('../../lib/hot-chain-svg/src/call');
const compile = require('../../lib/hot-chain-svg/src/compile');
const deploy = require('../../lib/hot-chain-svg/src/deploy');

const SOURCE = path.join(__dirname, '..', '..', 'src', 'MoonInk.sol');

async function main() {
  const { vm, pk } = await boot();

  async function handler() {
    const { abi, bytecode } = compile(SOURCE);
    const address = await deploy(vm, pk, bytecode);
    const result = await call(vm, address, abi, 'example');
    return result;
  }

  const { notify } = await serve(handler);

  fs.watch(path.dirname(SOURCE), notify);
  console.log('Watching', path.dirname(SOURCE));
  console.log('Serving  http://localhost:9901/');
}

main();
