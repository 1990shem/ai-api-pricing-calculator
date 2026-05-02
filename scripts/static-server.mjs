import { createReadStream, existsSync, statSync } from "node:fs";
import { createServer } from "node:http";
import { extname, join, normalize } from "node:path";

const root = normalize(new URL("..", import.meta.url).pathname.slice(1));
const port = Number.parseInt(process.env.PORT || "4173", 10);

const contentTypes = {
  ".css": "text/css; charset=utf-8",
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".txt": "text/plain; charset=utf-8",
  ".xml": "application/xml; charset=utf-8"
};

function resolvePath(urlPath) {
  const cleanPath = decodeURIComponent(urlPath.split("?")[0]).replace(/^\/+/, "");
  const target = normalize(join(root, cleanPath || "index.html"));
  if (!target.startsWith(root)) return null;
  if (existsSync(target) && statSync(target).isDirectory()) {
    return join(target, "index.html");
  }
  return target;
}

createServer((request, response) => {
  const target = resolvePath(request.url || "/");
  if (!target || !existsSync(target)) {
    response.writeHead(404, { "content-type": "text/plain; charset=utf-8" });
    response.end("Not found");
    return;
  }

  response.writeHead(200, {
    "content-type": contentTypes[extname(target)] || "application/octet-stream"
  });
  createReadStream(target).pipe(response);
}).listen(port, "127.0.0.1", () => {
  console.log(`Serving ${root} at http://127.0.0.1:${port}`);
});
