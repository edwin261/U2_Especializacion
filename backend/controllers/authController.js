const jwt = require("jsonwebtoken");
const bcrypt = require("bcryptjs");

const { User } = require("../models");

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({
            where: {
                email
            }
        });

        if (!user) {
            return res.status(404).json({
                message: "Usuario no encontrado"
            });
        }

        const validPassword = await bcrypt.compare(
            password,
            user.password_hash
        );

        if (!validPassword) {
            return res.status(401).json({
                message: "Contraseña incorrecta"
            });
        }

        const token = jwt.sign(
            {
                id: user.id,
                username: user.name,
                email: user.email
            },

            process.env.JWT_SECRET,
            {
                expiresIn: "8h"
            }
        );

        res.json({
            token,
            username: user.name
        });
    }
    catch (error) {
        console.log(error);
        res.status(400).json({
            message: error.message
        });
    }
};