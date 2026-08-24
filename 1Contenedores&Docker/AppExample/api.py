import joblib
import numpy as np

def predecir(edad, ingresos, deudas):
    # Cargar modelo
    modelo = joblib.load('modelo.pkl')

    # Predecir
    categoria = modelo.predict(np.array([edad, ingresos, deudas]).reshape(1,-1))
    return categoria[0]

if __name__ == "__main__":
    edad = int(input("Introduzca edad: "))
    ingresos = int(input("Introduzca ingresos anuales: "))
    deudas = int(input("Introduzca monto de los créditos: "))
    
    cat = predecir(edad, ingresos, deudas)
    print("Categoría predicha:", cat)
