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
  queueLimit: 0,
  timezone: '-05:00', // Zona horaria de Perú
  charset: 'utf8mb4'
});
// Ejecutar SET time_zone al inicializar conexiones
db.on('connection', (connection) => {
  connection.query("SET time_zone = '-05:00'");
});


// Exportación del pool
export default db;