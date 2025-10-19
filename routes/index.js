import express from "express";
import productoRoutes from "./producto.routes.js";
import categoriaRoutes from "./categoria.routes.js";
import marcaRoutes from "./marca.routes.js";
import proveedorRoutes from "./proveedor.routes.js";
import paisRoutes from "./pais.routes.js";
import clienteRoutes from "./cliente.routes.js";
import ubicacionRoutes from "./ubicacion.routes.js";

const router = express.Router();

router.use("/productos", productoRoutes);
router.use("/categorias", categoriaRoutes);
router.use("/marcas", marcaRoutes);
router.use("/proveedores", proveedorRoutes);
router.use("/paises", paisRoutes);
router.use("/clientes", clienteRoutes);
router.use("/ubicacion", ubicacionRoutes);

export default router;