import joblib
from sklearn.ensemble import RandomForestClassifier
import pandas as pd


def entrenar():
    # Leer set de datos
    dataset = pd.read_csv('train.csv')

    # Crear entradas (X) y salidas (y)
    X = dataset.drop('categoría', axis=1).to_numpy()
    y = dataset['categoría'].to_numpy()

    # Crear modelo de bosque aleatorio y entrenarlo    
    model = RandomForestClassifier(n_estimators=100, random_state=42)
    model.fit(X, y)
    
    # Guardar el modelo en formato pickle
    joblib.dump(model, 'modelo.pkl')

if __name__ == "__main__":
    entrenar()
