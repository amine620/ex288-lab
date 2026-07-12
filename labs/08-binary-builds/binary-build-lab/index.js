const http = require("http");
const server = http.createServer((req, res) => {
  res.writeHead(200);
  res.end("Hello from Binary Build! V2\n");
});
server.listen(8080);
console.log("Server running on port 8080");
