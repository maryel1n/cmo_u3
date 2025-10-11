/* eslint-disable max-len */
const { onRequest } = require("firebase-functions/v2/https");
const express = require("express");
const cors = require("cors");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

// Inicializa Admin SDK y Firestore
initializeApp();
const db = getFirestore();

// App Express
const app = express();
app.use(cors({ origin: true }));
app.use(express.json());

// Credenciales Basic Auth (defaults como el ejemplo del profe)
const requiredUser = process.env.BASIC_USER || "test";
const requiredPass = process.env.BASIC_PASS || "test2023";

// Middleware Basic Auth
function basicAuth(req, res, next) {
  const header = req.header("authorization") || req.header("Authorization");
  if (!header || !header.startsWith("Basic ")) {
    res.status(401).json({ ok: false, error: "Missing Authorization" });
    return;
  }
  const decoded = Buffer.from(header.replace("Basic ", ""), "base64").toString("utf8");
  const [user, pass] = decoded.split(":");
  if (user === requiredUser && pass === requiredPass) {
    next();
    return;
  }
  res.status(403).json({ ok: false, error: "Invalid credentials" });
}

// ---- Endpoints de productos ----

// GET /ejemplos/product_list_rest/
app.get("/ejemplos/product_list_rest/", basicAuth, async (_req, res) => {
  const snap = await db.collection("products").get();
  const listado = snap.docs.map((d) => {
    const x = d.data() || {};
    return {
      id: d.id,
      productName: x.productName || x.nombre || "(sin nombre)",
      price: Number.isFinite(x.price) ? x.price : 0,
      stock: Number.isFinite(x.stock) ? x.stock : 0,
      category: x.category || "general",
      estado: x.estado || "Activo",
    };
  });
  res.json({ listado });
});

// POST /ejemplos/product_create/
app.post("/ejemplos/product_create/", basicAuth, async (req, res) => {
  const b = req.body || {};
  if (!b.productName) {
    res.status(400).json({ ok: false, error: "productName es requerido" });
    return;
  }
  const ref = await db.collection("products").add({
    productName: b.productName,
    price: Number.isFinite(b.price) ? b.price : 0,
    stock: Number.isFinite(b.stock) ? b.stock : 0,
    category: b.category || "general",
    estado: b.estado || "Activo",
  });
  res.json({ ok: true, id: ref.id });
});

// PUT /ejemplos/product_update/:id
app.put("/ejemplos/product_update/:id", basicAuth, async (req, res) => {
  const { id } = req.params;
  const ref = db.collection("products").doc(id);
  const doc = await ref.get();
  if (!doc.exists) {
    res.status(404).json({ ok: false, error: "Producto no existe" });
    return;
  }
  await ref.update(req.body || {});
  res.json({ ok: true, id });
});

// DELETE /ejemplos/product_delete/:id
app.delete("/ejemplos/product_delete/:id", basicAuth, async (req, res) => {
  const { id } = req.params;
  const ref = db.collection("products").doc(id);
  const doc = await ref.get();
  if (!doc.exists) {
    res.status(404).json({ ok: false, error: "Producto no existe" });
    return;
  }
  await ref.delete();
  res.json({ ok: true, id });
});

// Exporta la API HTTP (us-central1)
exports.api = onRequest({ region: "us-central1" }, app);