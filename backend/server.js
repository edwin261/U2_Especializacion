const http = require("http");
const { Server } = require("socket.io");

const app = require("./app");

const configureChat = require("./sockets/chat.socket");

require("dotenv").config();

const server = http.createServer(app);

const io = new Server(server, {

    cors: {

        origin: process.env.CLIENT_URL,

        methods: ["GET", "POST"]

    }

});

configureChat(io);

const PORT = process.env.PORT || 3001;

async function startServer() {

    try {
        server.listen(PORT, () => {

            console.log(`Servidor iniciado en puerto ${PORT}`);

        });

    }

    catch (error) {

        console.log(error);

    }

}

startServer();