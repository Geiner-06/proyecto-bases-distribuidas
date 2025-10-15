# Sistema de Gestión de Estudios Médicos Distribuido

Proyecto del curso **Bases de Datos II** – TEC  
Arquitectura de tres motores de base de datos integrados mediante Docker Compose.

## Estructura
- **PostgreSQL:** Núcleo transaccional (`db_postgres`)
- **SQL Server:** Integración externa (`db_sqlserver`)
- **MongoDB:** Capa analítica (`db_mongo`)

## Cómo ejecutar
```bash
docker-compose up -d
