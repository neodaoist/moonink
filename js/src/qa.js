const fs = require('fs');
const os = require('os');
const path = require('path');
const boot = require('../../lib/hot-chain-svg/src/boot');
const call = require('../../lib/hot-chain-svg/src/call');
const compile = require('../../lib/hot-chain-svg/src/compile');
const deploy = require('../../lib/hot-chain-svg/src/deploy');
const { DOMParser } = require('xmldom');

const SOURCE = path.join(__dirname, '..', '..', 'src', 'MoonInk.sol');
const DESTINATION = path.join(os.tmpdir(), 'hot-chain-svg-');

async function main() {
  const { vm, pk } = await boot();
  const { abi, bytecode } = compile(SOURCE);
  const address = await deploy(vm, pk, bytecode);

  const tempFolder = fs.mkdtempSync(DESTINATION);
  console.log('Saving to', tempFolder);

  for (let i = 1; i < 256; i++) {
    const fileName = path.join(tempFolder, i + '.svg');
    console.log('Rendering', fileName);
    const svg = await call(vm, address, abi, 'render', [i]);
    fs.writeFileSync(fileName, svg);

    // Throws on invalid XML
    new DOMParser().parseFromString(svg);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
