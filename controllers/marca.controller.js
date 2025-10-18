import db from "../config/db.js";

export const getMarcas = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM marcas");
    res.json(rows);
  } catch (error) {
    console.error("Error al obtener marcas:", error);
    res.status(500).json({ message: "Error al obtener marcas" });
  }
};