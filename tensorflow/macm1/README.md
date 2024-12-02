pyenv install --list | grep 3\.11
pyenv install 3.11.10

pyenv virtualenv 3.11.10 py3.11.10
pyenv virtualenvs

mkdir tflow-macm1-py311 && cd $_
pyenv local py3.11.10
cat .python-version

python --version
python -m pip install --upgrade pip
pip install -r requirements.txt

pip list | grep tensorflow-m
tensorflow-macos             2.15.1
tensorflow-metal             1.1.0

python -c "import tensorflow as tf; print(tf.config.list_physical_devices())"
[PhysicalDevice(name='/physical_device:CPU:0', device_type='CPU'),
 PhysicalDevice(name='/physical_device:GPU:0', device_type='GPU')]




