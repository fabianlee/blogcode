#!/usr/bin/env python
# suggests using pinned version of pip modules: https://forums.developer.apple.com/forums/thread/683757?page=2
# https://gist.github.com/bhanukaManesha/0163a2d173593213424955a7c26bf8d5
# python -c "import tensorflow as tf; print(tf.config.list_physical_devices())"
import tensorflow as tf
import pprint

pprint.pprint(tf.config.list_physical_devices())
