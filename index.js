const express = require('express');
const app = express();
const PORT = process.env.PORT || 80;

// Ruta principal para el control de estado (Health-Check) y visualización
app.get('/', (req, res) => {
    res.status(200).send(`
        <div style="font-family: sans-serif; text-align: center; margin-top: 10%;">
            <h1>🚀 Servidor Desplegado con Webos</h1>
            <p>Pipeline de CI/CD funcionando mediante GitHub Actions, Docker Hub y AWS EC2.</p>
            <div style="display: inline-block; padding: 10px 20px; background-color: #28a745; color: white; border-radius: 5px;">
                Estado: ONLINE
            </div>
        </div>
    `);
});

app.listen(PORT, () => {
    console.log(`Aplicación corriendo en el puerto ${PORT}`);
});
