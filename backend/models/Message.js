const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");

const Message = sequelize.define("Message", {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },

    user_id: {
        type: DataTypes.INTEGER,
        allowNull: false
    },

    text: {
        type: DataTypes.TEXT,
        allowNull: false
    },

    created_at: {
        type: DataTypes.DATE
    }
},
{
    tableName: "Messages",
    timestamps: false
});

module.exports = Message;