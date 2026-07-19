const jwt = require("jsonwebtoken");

const { Message, User } = require("../models");

module.exports = (io) => {
    io.use((socket, next) => {
        const token = socket.handshake.auth.token;
        if (!token) {
            return next(new Error("Token requerido"));
        }

        try {
            const decoded = jwt.verify(
                token,
                process.env.JWT_SECRET
            );
            socket.user = decoded;
            next();
        }
        catch (error) {
            next(new Error("Token inválido"));
        }
    });

    io.on("connection", async (socket) => {
        console.log(
            `${socket.user.username} conectado`
        );

        try {
            const history = await Message.findAll({
                include: [
                    {
                        model: User,
                        attributes: [
                            "name"
                        ]
                    }
                ],
                limit: 10,
                order: [
                    [
                        "created_at",
                        "DESC"
                    ]
                ]
            });

           const formattedHistory = history
            .reverse()
            .map(message => ({
                id: message.id,
                username: message.User.name,
                text: message.text,
                created_at: message.created_at
            }));

            socket.emit("chat-history", formattedHistory);
        }
        catch (error) {
            console.log(error);
        }
        socket.on(
            "new-message",
            async (data) => {
                try {
                    const message = await Message.create({
                        user_id: socket.user.id,
                        text: data.text
                    });
                    const completeMessage = {
                        id: message.id,
                        username: socket.user.username,
                        text: message.text,
                        created_at: message.created_at
                    };
                    io.emit(
                        "receive-message",
                        completeMessage
                    );
                }
                catch (error) {
                    console.log(error);
                }
            }
        );
        socket.on(
            "disconnect",
            () => {
                console.log(
                    `${socket.user.username} desconectado`
                );
            }
        );
    });
};