const { DataTypes } = require("sequelize");
const sequelize = require("../config/database");


const Product = sequelize.define(
    "Product",
    {
        id: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true
        },


        name: {
            type: DataTypes.STRING(150),
            allowNull: false
        },


        price: {
            type: DataTypes.DECIMAL(10,2),
            allowNull: false
        },


        created_by: {
            type: DataTypes.INTEGER,
            allowNull: false
        },


        created_at: {
            type: DataTypes.DATE
        },


        updated_at: {
            type: DataTypes.DATE
        }
    },
    {
        tableName: "products",
        timestamps: false
        
    }
);

module.exports = Product;
