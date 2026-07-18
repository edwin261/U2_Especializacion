const {
    getProducts,
    getProductById,
    addProduct,
    getMyStatsCount
} = require("../mock/mockData");

exports.getProducts = async (req, res) => {
    try {
        const products = getProducts();
        res.json(products);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.getProductById = async (req, res) => {
    try {
        const product = getProductById(req.params.id);
        if (!product) {
            return res.status(404).json({ message: "Producto no encontrado" });
        }
        res.json(product);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

exports.createProduct = async (req, res) => {
    try {
        if (!req.body.name || req.body.price === undefined) {
            return res.status(400).json({
                message: "name y price son obligatorios"
            });
        }

        const product = addProduct(req.body, req.user.id);
        res.status(201).json(product);
    } catch (error) {
        res.status(500).json({
            message: error.message
        });
    }
};

exports.getMyStats = async (req, res) => {
    try {
        const products = getMyStatsCount(req.user.id);

        res.json({
            products
        });

    } catch (error) {
        res.status(500).json({
            message: error.message
        });
    }
};