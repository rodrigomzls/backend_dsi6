import express from "express";
import {
  getPaises,
  getDepartamentos,
  getDepartamentosByPais,
  getProvincias,
  getProvinciasByDepartamento,
  getDistritos,
  getDistritosByProvincia
} from "../controllers/ubicacion.controller.js";

const router = express.Router();

router.get("/paises", getPaises);
router.get("/departamentos", getDepartamentos);
router.get("/departamentos/pais/:paisId", getDepartamentosByPais);
router.get("/provincias", getProvincias);
router.get("/provincias/departamento/:departamentoId", getProvinciasByDepartamento);
router.get("/distritos", getDistritos);
router.get("/distritos/provincia/:provinciaId", getDistritosByProvincia);

export default router;