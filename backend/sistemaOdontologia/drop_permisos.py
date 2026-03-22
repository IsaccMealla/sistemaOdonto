import pymysql

# Conectar a la base de datos
conn = pymysql.connect(
    host='localhost',
    user='root',
    password='',
    database='sistema_odontologico',
    port=3306
)

cursor = conn.cursor()

# Eliminar tablas de permisos
tables = ['usuario_permiso', 'rol_permiso', 'permisos']

for table in tables:
    try:
        cursor.execute(f"DROP TABLE IF EXISTS {table}")
        print(f"Tabla {table} eliminada")
    except Exception as e:
        print(f"Error al eliminar {table}: {e}")

conn.commit()
cursor.close()
conn.close()
print("Tablas eliminadas exitosamente")
