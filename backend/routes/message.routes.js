const express = require("express");
const router = express.Router();
const auth = require("../middlewares/authJwt");
const controller = require("../controllers/messageController");

router.get(
    "/messages",
    auth,
    controller.getMessages
);

module.exports = router;