# 1. Especificar la versión de Python
FROM python:3.11.2

# 2. Definir el directorio de trabajo dentro del contenedor
WORKDIR /predictor

# 3. Copiar código fuente y requirements.txt
COPY modelo.pkl api.py requirements.txt ./

# 4. Instalar las dependencias
RUN pip install -r requirements.txt

# 5. Comando para ejecutar el contenedor
CMD ["python", "api.py"]