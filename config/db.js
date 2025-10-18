import mysql from "mysql2/promise";
import dotenv from "dotenv";

// Carga las variables del archivo .env
dotenv.config();

// Conexión a la base de datos
const db = await mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// Exportación de la conexión
export default db;

//comentario