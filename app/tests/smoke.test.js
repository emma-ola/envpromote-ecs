/**
 * Very lightweight test used by CI.
 * Fails fast if the app entrypoint is missing.
 */
const fs = require("fs");

if (!fs.existsSync("src/index.js")) {
    console.error("❌ src/index.js not found");
    process.exit(1);
}

console.log("✅ Smoke test passed");
