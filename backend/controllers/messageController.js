const { Message, User } = require("../models");

exports.getMessages = async (req, res) => {
    try {
        const messages = await Message.findAll({
            include: [
                {
                    model: User,
                    attributes: [
                        "name"
                    ]
                }
            ],
            order: [
                [
                    "created_at",
                    "DESC"
                ]
            ]
        });
        res.json(messages);
    }
    catch (error) {
        res.status(500).json(error.message);
    }
};