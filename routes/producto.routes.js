// src/routes/producto.routes.js
import express from "express";
import { verifyToken, requireRole } from "../middleware/auth.js";
import { 
  getProductos, 
  getProductoById, 
  createProducto, 
  updateProducto, 
  deleteProducto 
} from "../controllers/producto.controller.js";

const router = express.Router();

// Rutas públicas (sin autenticación) - solo lectura
router.get("/", getProductos);
router.get("/:id", getProductoById);

// Rutas protegidas para modificación
router.use(verifyToken);

router.post("/", requireRole([1]), createProducto); // Solo Admin
router.put("/:id", requireRole([1]), updateProducto); // Solo Admin
router.delete("/:id", requireRole([1]), deleteProducto); // Solo Admin

export default router;