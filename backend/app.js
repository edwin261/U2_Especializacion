const express = require("express");
const cors = require("cors");

require("dotenv").config();

const authRoutes = require("./routes/auth.routes");
const messageRoutes = require("./routes/message.routes");
const productRoutes = require("./routes/product.routes");
const app = express();
app.use(cors());
app.use(express.json());
app.use("/api/auth", authRoutes);
app.use("/api", messageRoutes);
app.use("/api", productRoutes);
module.exports = app;