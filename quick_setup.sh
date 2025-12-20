#!/bin/bash
# Quick Setup Script for ADP Project
# This script automates the initial setup process

set -e  # Exit on error

echo "=========================================="
echo "ADP Project Quick Setup"
echo "=========================================="
echo ""

# Check Python version
echo "Checking Python version..."
python3 --version || { echo "Error: Python 3 is required"; exit 1; }

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
else
    echo "Virtual environment already exists"
fi

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

# Install requirements
echo "Installing requirements..."
pip install -r requirements.txt

# Install robustbench
echo "Installing robustbench..."
pip install robustbench || echo "Warning: robustbench installation had issues, but continuing..."

# Create necessary directories
echo "Creating necessary directories..."
mkdir -p logs datasets clf_models/run/logs ncsnv2/run/logs

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Activate virtual environment: source venv/bin/activate"
echo "2. Download EBM models and add them to ncsnv2/run/logs you can use the one found here: https://drive.google.com/drive/folders/1A0hnC0MJzlsqxXzUSyJbUlrqL6wa70Z4?usp=drive_link"
echo "3. this setup will use RobustBench models for the Classifier Model
echo "4. Run quick test: python main.py --config cifar10_ultra_quick.yml"
echo "Note: The first time you run this will take longer to run as it downloads the models. This only happens on the first run, and all the following runs will just use the downloaded models
echo ""
echo "For detailed instructions, see readme.md"
echo ""

