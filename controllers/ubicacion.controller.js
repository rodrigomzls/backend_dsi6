import db from "../config/db.js";

export const getPaises = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM pais");
    res.json(rows);
  } catch (error) {
    console.error("Error al obtener países:", error);
    res.status(500).json({ message: "Error al obtener países" });
  }
};

export const getDepartamentos = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM departamento");
    res.json(rows);
  } catch (error) {
    console.error("Error al obtener departamentos:", error);
    res.status(500).json({ message: "Error al obtener departamentos" });
  }
};

export const getDepartamentosByPais = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM departamento WHERE id_pais = ?", [req.params.paisId]);
    res.json(rows);
  } catch (error) {
    console.error("Error al obtener departamentos:", error);
    res.status(500).json({ message: "Error al obtener departamentos" });
  }
};

export const getProvincias = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM provincia");
    res.json(rows);
  } catch (error) {
    console.error("Error al obtener provincias:", error);
    res.status(500).json({ message: "Error al obtener provincias" });
  }
};

export const getProvinciasByDepartamento = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM provincia WHERE id_departamento = ?", [req.params.departamentoId]);
    res.json(rows);
  } catch (error) {
    console.error("Error al obtener provincias:", error);
    res.status(500).json({ message: "Error al obtener provincias" });
  }
};

export const getDistritos = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM distrito");
    res.json(rows);
  } catch (error) {
    console.error("Error al obtener distritos:", error);
    res.status(500).json({ message: "Error al obtener distritos" });
  }
};

export const getDistritosByProvincia = async (req, res) => {
  try {
    const [rows] = await db.query("SELECT * FROM distrito WHERE id_provincia = ?", [req.params.provinciaId]);
    res.json(rows);
  } catch (error) {
    console.error("Error al obtener distritos:", error);
    res.status(500).json({ message: "Error al obtener distritos" });
  }
};