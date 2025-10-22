import mysql from "mysql2/promise";
import dotenv from "dotenv";

// Carga las variables del archivo .env
dotenv.config();

// Crear pool de conexiones
const db = mysql.createPool({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Exportación del pool
export default db;