# ADP Project Setup Guide

This guide will help you set up and run the Adversarial Denoising Purification (ADP) project from scratch.

## Skip the guide

If you want to skip the guide and only intrested in a quick setup just go to this repo's directory once you clone it and run:
```bash
./quick_setup.sh
```
and then follow the steps the cmd provides after it is done

 
## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Installing Dependencies](#installing-dependencies)
4. [Downloading Pre-trained Models](#downloading-pre-trained-models)
5. [Quick Test Run](#quick-test-run)
6. [Running Full Experiments](#running-full-experiments)
7. [Troubleshooting](#troubleshooting)
8. [Code Changes Summary](#code-changes-summary)

---

## Prerequisites

- Python 3.8 or higher
- pip (Python package manager)

**Note**: This project works on both CPU and GPU. GPU is recommended for faster execution but not required.

---

## Initial Setup

### 1. Navigate to the Project Directory

```bash
cd /path/to/adp
```

### 2. Create a Virtual Environment

It's recommended to use a virtual environment to avoid conflicts with other Python projects:

```bash
# Create virtual environment
python3 -m venv venv

# Activate virtual environment
# On macOS/Linux:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate
```

---

## Installing Dependencies

### 1. Install Base Requirements

```bash
# Make sure virtual environment is activated
pip install --upgrade pip
pip install -r requirements.txt
```

### 2. Install RobustBench (for Pre-trained Models)

```bash
pip install robustbench
```

**Note**: `robustbench` may try to install `autoattack` as a dependency. If you encounter issues, the code has been modified to handle this gracefully.

### 3. Verify Installation

```bash
python -c "import torch; import torchvision; import robustbench; print('All dependencies installed successfully!')"
```

---

## Downloading Pre-trained Models

The project requires **two separate types** of pre-trained models:

1. **Classifier Model**: For classifying images (can use RobustBench models, which is what I did for this project)
2. **EBM (Energy-Based Model)**: For purifying adversarial examples (must download separately, I used the one provided here: https://drive.google.com/drive/folders/1217uhIvLg9ZrYNKOR3XTRFSurt4miQrd . So this is what you will have by default, it can be found inside the ncsnv2/run directory)

**Important**: RobustBench only provides classifier models, **not** EBM models. You need both!

### Step 1: Classifier Model (Using RobustBench - Recommended)

The project has been configured to use RobustBench models for the classifier, which are downloaded automatically. The following models are supported:
- `cifar10_carmon` - Carmon2019Unlabeled model
- `cifar10_wu` - Wu2020Adversarial_extra model
- `cifar10_zhang` - Zhang2019Theoretically model

These will be downloaded automatically when you run the code for the first time (no manual download needed). following runs will skip the download step and use the downloaded models from the previous run.

### Step 2: EBM Model (Required - Must Download)

The EBM (Energy-Based Model) is used for purification and **cannot** be replaced by RobustBench. You must download it separately:

1. Download the `exp.zip` file from: https://drive.google.com/drive/folders/1217uhIvLg9ZrYNKOR3XTRFSurt4miQrd?usp=sharing
(the cifar10 that I used for testing this can be found here: https://drive.google.com/drive/folders/1A0hnC0MJzlsqxXzUSyJbUlrqL6wa70Z4?usp=drive_link)

2. Extract the zip file

3. Copy the EBM checkpoint to the project:
   ```bash
   # Create directory
   mkdir -p ncsnv2/run/logs/cifar10
   
   # Copy EBM checkpoint (look for checkpoint.pth or checkpoint_300000.pth)
   cp /path/to/exp/logs/cifar10/checkpoint*.pth ncsnv2/run/logs/cifar10/checkpoint.pth
   
   # Copy config file (required)
   cp ncsnv2/configs/cifar10.yml ncsnv2/run/logs/cifar10/config.yml
   ```

4. Verify the structure:
   ```bash
   ls -lh ncsnv2/run/logs/cifar10/
   # Should show:
   # - checkpoint.pth (should be ~475MB)
   # - config.yml (should be ~1KB)
   ```


### Why Do We Need Both Models?

- **Classifier Model**: Classifies images into categories (e.g., "cat", "dog", "car"). RobustBench provides these.
- **EBM Model**: Purifies/denoises adversarial examples by learning the data distribution. This is a different type of model (NCSNv2) that RobustBench doesn't provide.
- I didnt understand this part at the beggning, but thank god for AI :)

**The workflow**: Adversarial Image → [EBM purifies it] → [Classifier classifies the cleaned image]

---

## Quick Test Run

To verify everything is working, run the ultra-quick test configuration:

```bash
# Make sure virtual environment is activated
source venv/bin/activate

# Run ultra-quick test (completes in ~30 seconds)
python main.py --config cifar10_ultra_quick.yml
```

**Expected Output:**
- The script will load models, process 1 image, and complete in a couple of seconds
- Results will be saved in `logs/imgs/` or `logs/NAME_YOU_CHOSE/` if you used --log flag at the end of the cmd above
- You should see progress messages like:
  ```
  [timestamp] Start importing dataset CIFAR10
  [timestamp] Finished importing dataset CIFAR10
  [timestamp] Start importing network
  [timestamp] Finished importing networks
  [timestamp] Epoch 0
  [timestamp] Epoch 0: X.XX seconds to attack 1 data
  [timestamp] Epoch 0: Begin purifying 1 attacked images
  [timestamp] Epoch 0: X.XX seconds to purify 1 attacked images
  ```

**If this works, you're all set!**

---

## Running Full Experiments

### Using Pre-configured Config Files

The `configs/` directory contains several pre-configured experiment files:

- **`cifar10_bpda_eot_sigma025_eot15.yml`** - is the one mentioned in the original readme from the project i forked from

### Running an Experiment

```bash
# Activate virtual environment
source venv/bin/activate

# Run with a specific config
python main.py --config <config_name>.yml --log <log_name>
# Or remove the log flag forresult to go in the logs/imgs/ directory
python main.py --config <config_name>.yml

# Example: Run the full experiment
python main.py --config cifar10_bpda_eot_sigma025_eot15.yml --log full_experiment
```

### Understanding Config Files (AI Generated)

Key parameters you can adjust in config files:

- **`structure.bsize`**: Batch size (number of images processed at once)
- **`structure.start_epoch`** / **`structure.end_epoch`**: Which batches to process (0 = first batch only)
- **`attack.attack_method`**: Attack type (`clf_pgd` = simple, `bpda_strong` = advanced)
- **`attack.iter`**: Number of attack iterations
- **`purification.max_iter`**: Number of purification iterations
- **`purification.rand_smoothing_ensemble`**: Number of ensemble runs
- **`device.ebm_device`** / **`device.clf_device`**: Device to use (`cpu` or `cuda`)

### Viewing Results (AI Generated)

Results are saved in the `logs/<log_name>/` directory:
- **`df.pkl`**: Results as a pandas DataFrame (can be loaded with `pickle`)
- **`log_progress`**: Text log of progress
- **`acc_denoising_iters.pdf`**: Plot of accuracy vs. denoising iterations
- **`config.yml`**: Copy of the config used

---

## Code Changes Summary

This version includes several improvements and fixes:

### 1. **Dynamic Path Resolution**
   - **Files**: `utils/importData.py`, `networks/__init__.py`, `clf_models/networks/__init__.py`
   - **Change**: Replaced hardcoded paths with dynamic path resolution
   - **Benefit**: Code works regardless of where the project is located

### 2. **Optional Imports**
   - **File**: `runners/empirical.py`
   - **Change**: Made `RefineNetDilated` and `load_model` imports optional with try-except blocks
   - **Benefit**: Code runs even if some optional dependencies are missing

### 3. **RobustBench Integration**
   - **File**: `runners/empirical.py`
   - **Change**: Modified `load_model` import to handle `autoattack` dependency issues
   - **Benefit**: Can use RobustBench models without requiring `autoattack`

### 4. **Device Handling**
   - **File**: `ncsnv2/models/ncsnv2.py`
   - **Change**: Replaced hardcoded `'cuda:0'` with dynamic device from input tensor
   - **Benefit**: Works on CPU, any CUDA device, or when CUDA is not available

### 5. **Config File Respect**
   - **File**: `runners/empirical.py`
   - **Change**: Fixed `end_epoch` to respect config file values instead of always using 99
   - **Benefit**: Can control how many batches to process via config files

### 6. **Pandas Compatibility**
   - **File**: `runners/empirical.py`
   - **Change**: Replaced deprecated `df.append()` with `pd.concat()` for Pandas 2.0+ compatibility
   - **Benefit**: Works with modern Pandas versions

### 7. **Namespace Conversion**
   - **File**: `runners/empirical.py`
   - **Change**: Added `dict2namespace` conversion for EBM config to fix AttributeError
   - **Benefit**: Config attributes can be accessed with dot notation

### 8. **Requirements Updates**
   - **File**: `requirements.txt`
   - **Change**: Fixed typo (`torchvisiion` → `torchvision`) and added `tqdm`
   - **Benefit**: All dependencies properly listed

All changes are documented with `# CHANGED:` comments in the code for easy reference.

---

## Troubleshooting (AI Generated)

### Issue: `ModuleNotFoundError: No module named 'torch'`

**Solution**: Make sure you've activated the virtual environment and installed requirements:
```bash
source venv/bin/activate
pip install -r requirements.txt
```

### Issue: `FileNotFoundError: ... checkpoint.pth`

**Solution**: You need to download the EBM models. See [Downloading Pre-trained Models](#downloading-pre-trained-models).

### Issue: `AssertionError: Torch not compiled with CUDA enabled`

**Solution**: This happens when the config specifies CUDA but your system doesn't have it. Edit the config file:
```yaml
device:
  ebm_device: "cpu"  # Change from "cuda" to "cpu"
  clf_device: "cpu"   # Change from "cuda" to "cpu"
```

### Issue: `ImportError: cannot import name 'TinyImageNet'`

**Solution**: This is handled automatically. If you're not using TinyImageNet dataset, you can ignore this.

### Issue: `AttributeError: 'DataFrame' object has no attribute 'append'`

**Solution**: This has been fixed in the code. Make sure you're using the latest version. If you still see this, update pandas:
```bash
pip install --upgrade pandas
```

### Issue: Models taking too long to download

**Solution**: RobustBench models download automatically on first use. This may take a few minutes. The models are cached, so subsequent runs will be faster.

### Issue: Experiment taking too long

**Solution**: Use the quick test config first and ensure everything works:
- `cifar10_ultra_quick.yml`

---

## Quick Reference (AI Generated)

### Essential Commands

```bash
# Setup
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip install robustbench

# Quick test
python main.py --config cifar10_ultra_quick.yml --log test

# Full experiment
python main.py --config cifar10_bpda_eot_sigma025_eot15.yml --log full_run
```

### Directory Structure

```
adp/
├── configs/              # Configuration files
├── logs/                 # Experiment results
├── datasets/             # Downloaded datasets (auto-created)
├── clf_models/           # Classifier models
│   └── run/logs/         # RobustBench models cache
├── ncsnv2/               # EBM models
│   └── run/logs/         # EBM checkpoints
├── attacks/              # Attack implementations
├── purification/         # Purification methods
├── runners/              # Main execution code
├── utils/                # Utility functions
└── main.py              # Entry point
```

---

## Getting Help (AI Genearted)

If you encounter issues not covered in this guide:

1. Check the error message carefully - it often indicates what's missing
2. Verify all dependencies are installed: `pip list`
3. Ensure virtual environment is activated: `which python` should show `venv/bin/python`
4. Check that models are in the correct locations (see [Downloading Pre-trained Models](#downloading-pre-trained-models))
5. Try the ultra-quick test first to isolate issues

---

## Next Steps (AI Generated)

Once you have the basic setup working:

1. **Explore Config Files**: Look at `configs/` to understand different experiment settings
2. **Run Different Attacks**: Try different attack methods (`clf_pgd`, `bpda_strong`)
3. **Adjust Parameters**: Modify config files to test different purification settings
4. **Analyze Results**: Load `df.pkl` files to analyze results programmatically

Good luck with your experiments!

