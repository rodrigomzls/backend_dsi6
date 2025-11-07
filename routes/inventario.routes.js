// src/routes/inventario.routes.js
import express from "express";
import { verifyToken, requireRole } from "../middleware/auth.js";
import { 
  getDashboardData,
  generarReporteStock,
  getProductosStockBajo,
  getLotesPorCaducar
} from "../controllers/inventario.controller.js";

const router = express.Router();

// Dashboard de inventario
router.get("/dashboard", verifyToken, requireRole([1, 4], 'inventario'), getDashboardData);

// Reportes
router.post("/reportes/stock", verifyToken, requireRole([1, 4], 'inventario_reportes'), generarReporteStock);

// Alertas
router.get("/alertas/stock-bajo", verifyToken, requireRole([1, 4], 'inventario'), getProductosStockBajo);
router.get("/alertas/caducidad", verifyToken, requireRole([1, 4], 'inventario'), getLotesPorCaducar);

export default router;