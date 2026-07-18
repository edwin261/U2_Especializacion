const { getMessages } = require("../mock/mockData");

exports.getMessages = async (req, res) => {
    try {
        const messages = getMessages();
        res.json(messages);
    }
    catch (error) {
        res.status(500).json(error.message);
    }
};