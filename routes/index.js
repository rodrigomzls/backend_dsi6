// src/routes/index.js
import express from "express";
import productoRoutes from "./producto.routes.js";
import categoriaRoutes from "./categoria.routes.js";
import marcaRoutes from "./marca.routes.js";
import proveedorRoutes from "./proveedor.routes.js";
import paisRoutes from "./pais.routes.js";
import clienteRoutes from "./cliente.routes.js";
import ubicacionRoutes from "./ubicacion.routes.js";
import authRoutes from "./auth.routes.js";
import ventaRoutes from "./venta.routes.js";
import repartidorRoutes from './repartidor.routes.js';

const router = express.Router();

// Rutas públicas (sin autenticación)
router.use("/auth", authRoutes);

// Rutas protegidas (con autenticación)
router.use("/productos", productoRoutes);
router.use("/categorias", categoriaRoutes);
router.use("/marcas", marcaRoutes);
router.use("/proveedores", proveedorRoutes);
router.use("/paises", paisRoutes);
router.use("/clientes", clienteRoutes);
router.use("/ubicacion", ubicacionRoutes);
router.use("/ventas", ventaRoutes);
// ✅ CORREGIDO: Cambiar de '/api/repartidores' a '/repartidores'
router.use("/repartidores", repartidorRoutes);

export default router;