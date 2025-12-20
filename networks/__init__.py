import sys
import os
# CHANGED: Replaced hardcoded path_root with dynamic path resolution.
# Previously used a hardcoded absolute path which would break when the repository
# is moved or used on different machines. This change makes the code portable by
# dynamically determining the project root directory relative to this file's location.
path_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(path_root)

from clf_models.networks.simpleConv import *
from clf_models.networks.simpleMLP import *
from clf_models.networks.resnet import *
from clf_models.networks.wide_resnet import *
