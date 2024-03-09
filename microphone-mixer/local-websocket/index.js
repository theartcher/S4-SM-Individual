import { WebSocketServer } from "ws";

const port = 8080;

const wss = new WebSocketServer({ port: port });

wss.on("connection", function connection(ws) {
  console.log("New client connected!");

  ws.on("message", function incoming(data) {
    console.log("received: %s", data.toString());

    // Broadcast the received message to all clients
    wss.clients.forEach(function each(client) {
      if (client !== ws && client.readyState === client.OPEN) {
        client.send(data.toString());
      }
    });
  });
});
