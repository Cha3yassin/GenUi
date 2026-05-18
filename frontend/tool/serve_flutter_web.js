const fs = require('fs');
const http = require('http');
const path = require('path');

const root = path.resolve(__dirname, '..', 'build', 'web');
const port = Number(process.env.PORT || 7357);
const logPath = path.resolve(__dirname, '..', 'node-server.log');

function log(message) {
  fs.appendFileSync(logPath, `${new Date().toISOString()} ${message}\n`);
}

process.on('uncaughtException', (error) => {
  log(`uncaughtException: ${error.stack || error.message}`);
  process.exit(1);
});

process.on('unhandledRejection', (error) => {
  log(`unhandledRejection: ${error && error.stack ? error.stack : error}`);
  process.exit(1);
});

const types = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.wasm': 'application/wasm',
};

function fileForUrl(url) {
  const cleanPath = decodeURIComponent((url || '/').split('?')[0]);
  const requested = path.normalize(path.join(root, cleanPath));
  if (!requested.startsWith(root)) {
    return path.join(root, 'index.html');
  }
  if (fs.existsSync(requested) && fs.statSync(requested).isFile()) {
    return requested;
  }
  return path.join(root, 'index.html');
}

http
  .createServer((req, res) => {
    const filePath = fileForUrl(req.url);
    const ext = path.extname(filePath).toLowerCase();
    res.writeHead(200, {
      'Content-Type': types[ext] || 'application/octet-stream',
      'Cache-Control': 'no-store',
    });
    fs.createReadStream(filePath).pipe(res);
  })
  .listen(port, '0.0.0.0', () => {
    log(`Serving ${root} at http://localhost:${port}`);
  });
