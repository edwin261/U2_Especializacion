const express = require("express");
const auth = require("../middlewares/authJwt");
const controller = require("../controllers/productController");

const router = express.Router();

router.get(
    "/products",
    auth,
    controller.getProducts
);

router.get(
    "/products/my-count",
    auth,
    controller.getMyProductCount
);

router.post(
    "/products",
    auth,
    controller.createProduct
);

router.put(
    "/products/:id",
    auth,
    controller.updateProduct
);

router.delete(
    "/products/:id",
    auth,
    controller.deleteProduct
);

module.exports = router;
