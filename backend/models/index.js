const sequelize = require("../config/database");

const User = require("./User");
const Message = require("./Message");
const Product = require("./Product");

/* Relaciones existentes */

User.hasMany(Message, {
    foreignKey: "user_id"
});

Message.belongsTo(User, {
    foreignKey: "user_id"
});

/* Nueva relación */

User.hasMany(Product, {
    foreignKey: "created_by"
});

Product.belongsTo(User, {
    foreignKey: "created_by"
});

module.exports = {
    sequelize,
    User,
    Message,
    Product
};