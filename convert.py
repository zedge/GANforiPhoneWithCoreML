from coremltools.converters.keras import convert
from keras.models import model_from_json

model = None
with open('generator.json', 'r') as f:
    model = model_from_json(f.read())
model.load_weights('generator.h5')

coreml_model = convert(model)
coreml_model.save('mnistGenerator.mlmodel')
