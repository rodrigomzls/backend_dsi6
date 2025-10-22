// src/routes/venta.routes.js
import express from 'express';
import { 
    getVentas, 
    getVentaById, 
    createVenta, 
    updateEstadoVenta,
    getVentasPorEstado,  // ✅ AGREGAR ESTA IMPORTACIÓN
    asignarRepartidor    // ✅ AGREGAR ESTA IMPORTACIÓN
} from '../controllers/venta.controller.js';
import { verifyToken, requireRole } from '../middleware/auth.js';

const router = express.Router();

// Todas las rutas requieren autenticación
router.use(verifyToken);

// Rutas existentes
router.get('/', requireRole([1, 2]), getVentas); // Admin y Vendedor
router.get('/:id', requireRole([1, 2]), getVentaById);
router.post('/', requireRole([1, 2]), createVenta); // Ambos pueden crear
router.patch('/:id/estado', requireRole([1]), updateEstadoVenta); // Solo Admin cambia estado

// ✅ NUEVAS RUTAS - Agregar protección de roles
router.get('/estado/:estadoId', requireRole([1, 2]), getVentasPorEstado); // Admin y Vendedor
router.patch('/:id/asignar-repartidor', requireRole([1]), asignarRepartidor); // Solo Admin

export default router;