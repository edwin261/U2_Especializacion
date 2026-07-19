const { Product, User } = require("../models");

const productInclude = [
    {
        model: User,
        attributes: [
            "name"
        ]
    }
];

const canManageProduct = (product, user) => {
    return product.created_by === user.id || user.role === "admin";
};

exports.getProducts = async (req, res) => {
    try {
        const products = await Product.findAll({
            include: productInclude,
            order: [
                [
                    "created_at",
                    "DESC"
                ]
            ]
        });

        res.json(products);
    }
    catch (error) {
        res.status(500).json({
            message: error.message
        });
    }
};

exports.getMyProductCount = async (req, res) => {
    try {
        const count = await Product.count({
            where: {
                created_by: req.user.id
            }
        });

        res.json({
            count
        });
    }
    catch (error) {
        res.status(500).json({
            message: error.message
        });
    }
};

exports.createProduct = async (req, res) => {
    try {
        const { name, price } = req.body;

        if (!name || price === undefined || price === "") {
            return res.status(400).json({
                message: "Nombre y precio son requeridos"
            });
        }

        if (Number(price) < 0) {
            return res.status(400).json({
                message: "El precio no puede ser negativo"
            });
        }

       try {
    const product = await Product.create({
        name,
        price,
        created_by: req.user.id
    });

    res.json(product);

} catch (err) {
    console.log(err);
    console.log(err.parent);
    console.log(err.original);

    res.status(500).json(err);
}

        const savedProduct = await Product.findByPk(product.id, {
            include: productInclude
        });

        res.status(201).json(savedProduct);
    }
    catch (error) {
        res.status(400).json({
            message: error.message
        });
    }
};

exports.updateProduct = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, price } = req.body;
        const product = await Product.findByPk(id);

        if (!product) {
            return res.status(404).json({
                message: "Producto no encontrado"
            });
        }

        if (!canManageProduct(product, req.user)) {
            return res.status(403).json({
                message: "No tienes permisos para modificar este producto"
            });
        }

        if (price !== undefined && price !== "" && Number(price) < 0) {
            return res.status(400).json({
                message: "El precio no puede ser negativo"
            });
        }

        await product.update({
            name: name || product.name,
            price: price === undefined || price === ""
                ? product.price
                : price
        });

        const updatedProduct = await Product.findByPk(product.id, {
            include: productInclude
        });

        res.json(updatedProduct);
    }
    catch (error) {
        res.status(400).json({
            message: error.message
        });
    }
};

exports.deleteProduct = async (req, res) => {
    try {
        const { id } = req.params;
        const product = await Product.findByPk(id);

        if (!product) {
            return res.status(404).json({
                message: "Producto no encontrado"
            });
        }

        if (!canManageProduct(product, req.user)) {
            return res.status(403).json({
                message: "No tienes permisos para eliminar este producto"
            });
        }

        await product.destroy();

        res.json({
            message: "Producto eliminado"
        });
    }
    catch (error) {
        res.status(500).json({
            message: error.message
        });
    }
};
