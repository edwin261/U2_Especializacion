const jwt = require("jsonwebtoken");
const { getUserByEmail } = require("../mock/mockData");

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = getUserByEmail(email);

        if (!user) {
            return res.status(404).json({
                message: "Usuario no encontrado"
            });
        }

        const validPassword = user.password === password;

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