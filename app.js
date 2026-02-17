// src/app.js
import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import db from "./config/db.js";
import indexRoutes from "./routes/index.js"; // centraliza rutas
  

dotenv.config();
// 🔧 CONFIGURAR ZONA HORARIA PARA TODO EL BACKEND
process.env.TZ = 'America/Lima';
console.log('⏰ Zona horaria del backend configurada a:', process.env.TZ);
console.log('🕐 Hora actual backend:', new Date().toString());
const app = express();

app.use(cors());
app.use(express.json());

// rutas
app.use("/api", indexRoutes);

// prueba básica
app.get("/", (req, res) => res.send("Backend DSI6 funcionando"));


// arrancar y test DB al inicio
const PORT = process.env.PORT || 4000;
app.listen(PORT, async () => {
  console.log(`Servidor corriendo en http://localhost:${PORT} 🥵`);
  try {
    const [rows] = await db.query("SELECT 1+1 AS result");
    console.log("Conexión a DB OK");
  } catch (err) {
    console.error("Error conectando a la DB x.X", err.message);
  }
});
