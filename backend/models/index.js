const sequelize = require("../config/database");

const User = require("./User");
const Message = require("./Message");

User.hasMany(Message, {
    foreignKey: "user_id"
});

Message.belongsTo(User, {
    foreignKey: "user_id"
});

module.exports = {
    sequelize,
    User,
    Message
};