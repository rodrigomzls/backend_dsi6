// src/app.js
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import db from "./config/db.js";
import indexRoutes from "./routes/index.js";
import paths from './config/paths.js'; // ✅ Importar configuración de rutas

dotenv.config();

// Configurar zona horaria
process.env.TZ = 'America/Lima';
console.log('⏰ Zona horaria del backend:', process.env.TZ);

const app = express();

app.use(cors());
app.use(express.json());

// ✅ SERVIR ARCHIVOS ESTÁTICOS USANDO RUTAS RELATIVAS
console.log('📁 Sirviendo archivos estáticos desde:', paths.frontend.assets);
app.use(paths.urls.assets, express.static(paths.frontend.assets));

// Rutas
app.use("/api", indexRoutes);

// Ruta de prueba
app.get("/", (req, res) => res.send("Backend DSI6 funcionando"));

const PORT = process.env.PORT || 4000;
app.listen(PORT, async () => {
  console.log(`🚀 Servidor corriendo en http://localhost:${PORT}`);
  try {
    const [rows] = await db.query("SELECT 1+1 AS result");
    console.log("✅ Conexión a DB OK");
  } catch (err) {
    console.error("❌ Error conectando a la DB:", err.message);
  }
});