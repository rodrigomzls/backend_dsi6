import express from "express";
import { getProveedores } from "../controllers/proveedor.controller.js";

const router = express.Router();

router.get("/", getProveedores);

export default router;