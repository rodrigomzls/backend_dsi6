// src/routes/movimiento_stock.routes.js
import express from "express";
import { verifyToken, requireRole } from "../middleware/auth.js";
import { 
  getMovimientos, 
  getMovimientosByProducto, 
  createMovimiento,
  updateMovimiento,
  deleteMovimiento
} from "../controllers/movimiento_stock.controller.js";

const router = express.Router();

// Rutas para movimientos de stock (solo Admin y Almacenero)
router.get("/", verifyToken, requireRole([1, 4], 'inventario_movimiento'), getMovimientos);
router.get("/producto/:id_producto", verifyToken, requireRole([1, 4], 'inventario_movimiento'), getMovimientosByProducto);
router.post("/", verifyToken, requireRole([1, 4], 'inventario_movimiento'), createMovimiento);
router.put("/:id", verifyToken, requireRole([1, 4], 'inventario_movimiento'), updateMovimiento);
router.delete("/:id", verifyToken, requireRole([1, 4], 'inventario_movimiento'), deleteMovimiento);

export default router;