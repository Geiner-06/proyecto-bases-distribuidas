// ============================================================
// 1. Cambiar o crear la base de datos
// ============================================================
use analitica_medica_db;

// ============================================================
// 2. Crear la colección 'reportes_estudios'
// ============================================================
db.createCollection("reportes_estudios");

// ============================================================
// 3. Crear el usuario con permisos de lectura y escritura
// ============================================================
db.createUser({
    user: "usr_fdw_pg_mongo",
    pwd: "PasswordParaMongo_789!",
    roles: [
        {
            role: "readWrite",
            db: "analitica_medica_db"
        }
    ]
});
