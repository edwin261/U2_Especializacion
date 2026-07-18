const express = require("express");
const router = express.Router();
const auth = require("../middlewares/authJwt");
const controller = require("../controllers/productController");

router.get("/products/stats", auth, controller.getMyStats);
router.get("/products", auth, controller.getProducts);
router.get("/products/:id", auth, controller.getProductById);
router.post(
    "/products",
    auth,
    controller.createProduct
);

module.exports = router;
